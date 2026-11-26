#pragma once

#include <stdint.h>

constexpr int kAdcMin = 0;
constexpr int kAdcMax = 4095;
constexpr int kMinCalibrationSpan = 200;

struct ChannelCalibration {
  int rest;
  int pinch;
};

struct CalibrationSet {
  ChannelCalibration flex;
  ChannelCalibration contact;
};

inline bool adcReferenceValid(int value) {
  return value >= kAdcMin && value <= kAdcMax;
}

inline int absoluteSpan(const ChannelCalibration &calibration) {
  const int span = calibration.pinch - calibration.rest;
  return span < 0 ? -span : span;
}

inline bool channelCalibrationValid(const ChannelCalibration &calibration) {
  return adcReferenceValid(calibration.rest) &&
         adcReferenceValid(calibration.pinch) &&
         absoluteSpan(calibration) >= kMinCalibrationSpan;
}

inline bool calibrationValid(const CalibrationSet &calibration) {
  return channelCalibrationValid(calibration.flex) &&
         channelCalibrationValid(calibration.contact);
}

inline bool calibrationEqual(const CalibrationSet &left,
                             const CalibrationSet &right) {
  return left.flex.rest == right.flex.rest &&
         left.flex.pinch == right.flex.pinch &&
         left.contact.rest == right.contact.rest &&
         left.contact.pinch == right.contact.pinch;
}

inline bool captureStable(int minimum, int maximum, int calibrationSpan) {
  if (!adcReferenceValid(minimum) || !adcReferenceValid(maximum) ||
      minimum > maximum || calibrationSpan < kMinCalibrationSpan)
    return false;
  // La variación durante cada postura no debe ocupar más de 25 % de la
  // separación medida entre reposo y pinza.
  return (maximum - minimum) <= calibrationSpan / 4;
}

inline int normalizeReading(int raw, const ChannelCalibration &calibration) {
  if (!adcReferenceValid(raw) || !channelCalibrationValid(calibration))
    return 0;
  const int64_t span =
      static_cast<int64_t>(calibration.pinch) - calibration.rest;
  int64_t normalized =
      (static_cast<int64_t>(raw) - calibration.rest) * kAdcMax / span;
  if (normalized < kAdcMin)
    return kAdcMin;
  if (normalized > kAdcMax)
    return kAdcMax;
  return static_cast<int>(normalized);
}

inline uint32_t calibrationChecksum(const CalibrationSet &calibration) {
  // FNV-1a sobre las cuatro referencias; detecta registros incompletos o
  // incoherentes sin convertir la NVS en almacenamiento continuo.
  uint32_t hash = 2166136261u;
  const int values[] = {calibration.flex.rest, calibration.flex.pinch,
                        calibration.contact.rest, calibration.contact.pinch};
  for (int value : values) {
    const uint32_t word = static_cast<uint32_t>(value);
    for (unsigned shift = 0; shift < 32; shift += 8) {
      hash ^= (word >> shift) & 0xffu;
      hash *= 16777619u;
    }
  }
  return hash;
}

// Un FSR con pull-down puede producir 0 cuentas sin contacto. Solo admitir
// este extremo si se confirmó como reposo en la calibración del montaje.
// No permite distinguir físicamente un circuito abierto de reposo.
inline bool railSuspicious(int raw, const ChannelCalibration &ref,
                           bool allowLowRest, int margin = 4) {
  if (!adcReferenceValid(raw) || raw >= kAdcMax - margin) return true;
  if (raw > margin) return false;
  return !(allowLowRest && channelCalibrationValid(ref) &&
           ref.rest <= margin && ref.pinch > ref.rest);
}
