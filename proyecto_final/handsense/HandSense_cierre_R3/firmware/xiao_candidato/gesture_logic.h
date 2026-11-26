#pragma once

#include <stdint.h>

enum class GestureState {
  REPOSO,
  FLEXION,
  CONTACTO,
  LIBERACION,
  ESPERA_REPOSO
};
enum class GestureEvent {
  NINGUNO,
  COMPLETA,
  SIN_CONTACTO,
  SIN_FLEXION,
  SIN_LIBERACION
};

struct GestureResult {
  GestureState state;
  GestureEvent event;
  bool flexActive;
  bool contactActive;
  uint32_t repetitions;
  uint32_t incomplete;
};

class ThresholdLatch {
public:
  ThresholdLatch(int enterThreshold, int exitThreshold)
      : enter_(enterThreshold), exit_(exitThreshold) {}

  bool update(int value) {
    if (!active_ && value >= enter_)
      active_ = true;
    if (active_ && value <= exit_)
      active_ = false;
    return active_;
  }

  void clear() { active_ = false; }

private:
  int enter_;
  int exit_;
  bool active_ = false;
};

class FlexOnlyCounter {
public:
  FlexOnlyCounter(int enterThreshold, int exitThreshold)
      : flex_(enterThreshold, exitThreshold) {}

  bool update(int flexValue) {
    const bool active = flex_.update(flexValue);
    if (!armed_) {
      if (!active) armed_ = true;
      return false;
    }
    const bool completed = wasActive_ && !active;
    if (completed)
      ++count_;
    wasActive_ = active;
    return completed;
  }

  uint32_t count() const { return count_; }

  void invalidateAttempt() { flex_.clear(); wasActive_ = false; armed_ = false; }

private:
  ThresholdLatch flex_;
  bool wasActive_ = false;
  bool armed_ = true;
  uint32_t count_ = 0;
};

class GestureDetector {
public:
  GestureDetector(int flexEnter, int flexExit, int contactEnter,
                  int contactExit, uint32_t timeoutMs)
      : flex_(flexEnter, flexExit), contact_(contactEnter, contactExit),
        timeoutMs_(timeoutMs) {}

  GestureResult update(int flexValue, int contactValue, uint32_t nowMs) {
    const bool flexActive = flex_.update(flexValue);
    const bool contactActive = contact_.update(contactValue);
    GestureEvent event = GestureEvent::NINGUNO;

    // Tras encender, reiniciar o recalibrar, primero debe observarse reposo.
    // Así una entrada activa al arranque no crea un intento ficticio.
    if (!armed_) {
      if (!flexActive && !contactActive) {
        armed_ = true;
        resetAttempt();
      } else {
        state_ = GestureState::ESPERA_REPOSO;
      }
      return result(event, flexActive, contactActive);
    }

    if (state_ == GestureState::ESPERA_REPOSO) {
      if (!flexActive && !contactActive)
        resetAttempt();
      return result(event, flexActive, contactActive);
    }

    if (!attemptActive_) {
      if (!flexActive && !contactActive)
        return result(event, flexActive, contactActive);
      attemptActive_ = true;
      attemptStartMs_ = nowMs;
      // Una pinza estricta comienza con flexion sola. Contacto primero o
      // activacion simultanea se conservan como intento incompleto, pero nunca
      // pueden convertirse mas tarde en COMPLETA.
      validOrder_ = flexActive && !contactActive;
    }

    seenFlex_ = seenFlex_ || flexActive;
    seenContact_ = seenContact_ || contactActive;

    // Expiration wins over transitions, including a release on the deadline.
    if (uint32_t(nowMs - attemptStartMs_) >= timeoutMs_) {
      event = !validOrder_ ? invalidEvent_
                           : (seenContact_ ? GestureEvent::SIN_LIBERACION
                                           : GestureEvent::SIN_CONTACTO);
      ++incomplete_;
      state_ = GestureState::ESPERA_REPOSO;
      return result(event, flexActive, contactActive);
    }

    if (!validOrder_) {
      state_ = contactActive ? GestureState::CONTACTO : GestureState::FLEXION;
      if (!flexActive && !contactActive) {
        event = invalidEvent_;
        ++incomplete_;
        resetAttempt();
        return result(event, flexActive, contactActive);
      }
    } else if (state_ == GestureState::REPOSO ||
               state_ == GestureState::FLEXION) {
      state_ = GestureState::FLEXION;
      if (contactActive && flexActive) {
        state_ = GestureState::CONTACTO;
      } else if (!flexActive) {
        event = GestureEvent::SIN_CONTACTO;
        ++incomplete_;
        resetAttempt();
        return result(event, flexActive, contactActive);
      }
    } else if (state_ == GestureState::CONTACTO) {
      if (!flexActive && contactActive) {
        validOrder_ = false;
        invalidEvent_ = GestureEvent::SIN_LIBERACION;
      } else if (flexActive && !contactActive) {
        state_ = GestureState::LIBERACION;
      } else if (!flexActive && !contactActive) {
        event = GestureEvent::SIN_LIBERACION;
        ++incomplete_;
        resetAttempt();
        return result(event, flexActive, contactActive);
      }
    } else if (state_ == GestureState::LIBERACION) {
      if (contactActive) {
        if (!flexActive) {
          validOrder_ = false;
          invalidEvent_ = GestureEvent::SIN_LIBERACION;
        }
        state_ = GestureState::CONTACTO;
      } else if (!flexActive) {
        ++repetitions_;
        event = GestureEvent::COMPLETA;
        resetAttempt();
        return result(event, flexActive, contactActive);
      }
    }

    return result(event, flexActive, contactActive);
  }

  // Descarta la secuencia en curso sin perder los totales confirmados.
  void invalidateAttempt() {
    flex_.clear(); contact_.clear(); resetAttempt(); armed_ = false;
    state_ = GestureState::ESPERA_REPOSO;
  }

private:
  GestureResult result(GestureEvent event, bool flexActive,
                       bool contactActive) const {
    return {state_,        event,        flexActive,
            contactActive, repetitions_, incomplete_};
  }

  void resetAttempt() {
    state_ = GestureState::REPOSO;
    attemptActive_ = false;
    seenFlex_ = false;
    seenContact_ = false;
    validOrder_ = false;
    invalidEvent_ = GestureEvent::SIN_FLEXION;
  }

  ThresholdLatch flex_;
  ThresholdLatch contact_;
  uint32_t timeoutMs_;
  GestureState state_ = GestureState::REPOSO;
  bool attemptActive_ = false;
  bool seenFlex_ = false;
  bool seenContact_ = false;
  bool validOrder_ = false;
  GestureEvent invalidEvent_ = GestureEvent::SIN_FLEXION;
  uint32_t attemptStartMs_ = 0;
  uint32_t repetitions_ = 0;
  uint32_t incomplete_ = 0;
  bool armed_ = false;
};

inline const char *stateName(GestureState state) {
  switch (state) {
  case GestureState::REPOSO:
    return "REPOSO";
  case GestureState::FLEXION:
    return "FLEXION";
  case GestureState::CONTACTO:
    return "CONTACTO";
  case GestureState::LIBERACION:
    return "LIBERACION";
  case GestureState::ESPERA_REPOSO:
    return "ESPERA_REPOSO";
  }
  return "DESCONOCIDO";
}

inline const char *eventName(GestureEvent event) {
  switch (event) {
  case GestureEvent::NINGUNO:
    return "NINGUNO";
  case GestureEvent::COMPLETA:
    return "COMPLETA";
  case GestureEvent::SIN_CONTACTO:
    return "SIN_CONTACTO";
  case GestureEvent::SIN_FLEXION:
    return "SIN_FLEXION";
  case GestureEvent::SIN_LIBERACION:
    return "SIN_LIBERACION";
  }
  return "DESCONOCIDO";
}
