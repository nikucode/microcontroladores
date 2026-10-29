#pragma once

#include <stdint.h>

enum class GestureState { REPOSO, FLEXION, CONTACTO, LIBERACION, ESPERA_REPOSO };
enum class GestureEvent { NINGUNO, COMPLETA, SIN_CONTACTO, SIN_FLEXION, SIN_LIBERACION };

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
    if (!active_ && value >= enter_) active_ = true;
    if (active_ && value <= exit_) active_ = false;
    return active_;
  }

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
    const bool completed = wasActive_ && !active;
    if (completed) ++count_;
    wasActive_ = active;
    return completed;
  }

  uint32_t count() const { return count_; }

 private:
  ThresholdLatch flex_;
  bool wasActive_ = false;
  uint32_t count_ = 0;
};

class GestureDetector {
 public:
  GestureDetector(int flexEnter, int flexExit, int contactEnter, int contactExit,
                  uint32_t timeoutMs)
      : flex_(flexEnter, flexExit),
        contact_(contactEnter, contactExit),
        timeoutMs_(timeoutMs) {}

  GestureResult update(int flexValue, int contactValue, uint32_t nowMs) {
    const bool flexActive = flex_.update(flexValue);
    const bool contactActive = contact_.update(contactValue);
    GestureEvent event = GestureEvent::NINGUNO;

    if (state_ == GestureState::ESPERA_REPOSO) {
      if (!flexActive && !contactActive) resetAttempt();
      return result(event, flexActive, contactActive);
    }

    if (!attemptActive_) {
      if (!flexActive && !contactActive)
        return result(event, flexActive, contactActive);
      attemptActive_ = true;
      attemptStartMs_ = nowMs;
    }

    seenFlex_ = seenFlex_ || flexActive;
    seenContact_ = seenContact_ || contactActive;

    if (seenFlex_ && seenContact_) {
      if (contactActive)
        state_ = GestureState::CONTACTO;
      else if (flexActive)
        state_ = GestureState::LIBERACION;
      else {
        ++repetitions_;
        event = GestureEvent::COMPLETA;
        resetAttempt();
        return result(event, flexActive, contactActive);
      }
    } else if (flexActive) {
      state_ = GestureState::FLEXION;
    } else if (contactActive) {
      state_ = GestureState::CONTACTO;
    } else {
      event = seenFlex_ ? GestureEvent::SIN_CONTACTO
                        : GestureEvent::SIN_FLEXION;
      ++incomplete_;
      resetAttempt();
      return result(event, flexActive, contactActive);
    }

    if (nowMs - attemptStartMs_ >= timeoutMs_) {
      event = (seenFlex_ && seenContact_)
                  ? GestureEvent::SIN_LIBERACION
                  : (seenFlex_ ? GestureEvent::SIN_CONTACTO
                               : GestureEvent::SIN_FLEXION);
      ++incomplete_;
      state_ = GestureState::ESPERA_REPOSO;
    }

    return result(event, flexActive, contactActive);
  }

 private:
  GestureResult result(GestureEvent event, bool flexActive,
                       bool contactActive) const {
    return {state_, event, flexActive, contactActive, repetitions_, incomplete_};
  }

  void resetAttempt() {
    state_ = GestureState::REPOSO;
    attemptActive_ = false;
    seenFlex_ = false;
    seenContact_ = false;
  }

  ThresholdLatch flex_;
  ThresholdLatch contact_;
  uint32_t timeoutMs_;
  GestureState state_ = GestureState::REPOSO;
  bool attemptActive_ = false;
  bool seenFlex_ = false;
  bool seenContact_ = false;
  uint32_t attemptStartMs_ = 0;
  uint32_t repetitions_ = 0;
  uint32_t incomplete_ = 0;
};

inline const char* stateName(GestureState state) {
  switch (state) {
    case GestureState::REPOSO: return "REPOSO";
    case GestureState::FLEXION: return "FLEXION";
    case GestureState::CONTACTO: return "CONTACTO";
    case GestureState::LIBERACION: return "LIBERACION";
    case GestureState::ESPERA_REPOSO: return "ESPERA_REPOSO";
  }
  return "DESCONOCIDO";
}

inline const char* eventName(GestureEvent event) {
  switch (event) {
    case GestureEvent::NINGUNO: return "NINGUNO";
    case GestureEvent::COMPLETA: return "COMPLETA";
    case GestureEvent::SIN_CONTACTO: return "SIN_CONTACTO";
    case GestureEvent::SIN_FLEXION: return "SIN_FLEXION";
    case GestureEvent::SIN_LIBERACION: return "SIN_LIBERACION";
  }
  return "DESCONOCIDO";
}
