#include <cassert>
#include <cstdint>
#include <iostream>

#include "../xiao_candidato/calibration_logic.h"
#include "../xiao_candidato/gesture_logic.h"

GestureDetector makeDetector(uint32_t timeout = 3000) {
  return GestureDetector(60, 35, 60, 35, timeout);
}

void arm(GestureDetector &detector, uint32_t now = 0) {
  const auto result = detector.update(0, 0, now);
  assert(result.state == GestureState::REPOSO);
  assert(result.event == GestureEvent::NINGUNO);
}

int main() {
  {
    auto d = makeDetector();
    arm(d);
    d.update(80, 0, 100);
    d.update(80, 80, 200);
    d.update(80, 0, 300);
    auto r = d.update(0, 0, 400);
    assert(r.event == GestureEvent::COMPLETA && r.repetitions == 1);
    assert(d.update(0, 0, 500).event == GestureEvent::NINGUNO);
  }
  {
    auto d = makeDetector();
    arm(d);
    FlexOnlyCounter reference(60, 35);
    reference.update(80);
    d.update(80, 0, 100);
    assert(reference.update(0));
    auto r = d.update(0, 0, 200);
    assert(r.event == GestureEvent::SIN_CONTACTO && reference.count() == 1);
  }
  {
    auto d = makeDetector();
    arm(d);
    d.update(0, 80, 100);
    assert(d.update(0, 0, 200).event == GestureEvent::SIN_FLEXION);
  }
  {
    auto d = makeDetector();
    arm(d);
    d.update(80, 0, 100);
    d.update(80, 80, 200);
    auto r = d.update(80, 80, 3100);
    assert(r.event == GestureEvent::SIN_LIBERACION);
    assert(d.update(80, 80, 3200).event == GestureEvent::NINGUNO);
    d.update(0, 0, 3300);
    assert(d.update(0, 0, 3400).state == GestureState::REPOSO);
  }
  {
    auto d = makeDetector();
    arm(d);
    assert(d.update(61, 0, 100).flexActive);
    assert(d.update(50, 0, 200).flexActive);
    assert(!d.update(34, 0, 300).flexActive);
  }
  {
    auto d = makeDetector();
    arm(d);
    d.update(0, 80, 100);
    d.update(80, 80, 200);
    d.update(80, 0, 300);
    auto r = d.update(0, 0, 400);
    assert(r.event == GestureEvent::SIN_FLEXION && r.repetitions == 0);
  }
  {
    auto d = makeDetector();
    arm(d);
    d.update(80, 80, 100);
    d.update(80, 0, 200);
    assert(d.update(0, 0, 300).event == GestureEvent::SIN_FLEXION);
  }
  {
    auto d = makeDetector();
    arm(d);
    d.update(80, 0, 100);
    d.update(80, 80, 200);
    d.update(0, 80, 300);
    assert(d.update(0, 0, 400).event == GestureEvent::SIN_LIBERACION);
  }
  {
    auto d = makeDetector();
    arm(d);
    d.update(0, 80, 100);
    assert(d.update(80, 80, 3100).event == GestureEvent::SIN_FLEXION);
    d.update(0, 0, 3200);
    assert(d.update(80, 0, 3300).state == GestureState::FLEXION);
  }
  {
    for (uint32_t elapsed : {4999u, 5000u, 5001u}) {
      auto d = makeDetector(5000);
      arm(d);
      d.update(80, 0, 100);
      d.update(80, 80, 200);
      d.update(80, 0, 300);
      auto r = d.update(0, 0, 100 + elapsed);
      assert((r.event == GestureEvent::COMPLETA) == (elapsed < 5000));
    }
  }
  {
    auto d = makeDetector(5000);
    arm(d);
    d.update(80, 0, 100);
    d.update(80, 80, 200);
    d.update(80, 0, 300);
    d.update(0, 80, 400);
    d.update(80, 80, 500);
    d.update(80, 0, 600);
    assert(d.update(0, 0, 700).event != GestureEvent::COMPLETA);
  }
  {
    auto d = makeDetector();
    auto r = d.update(80, 80, 0);
    assert(r.event == GestureEvent::NINGUNO &&
           r.state == GestureState::ESPERA_REPOSO);
    d.update(0, 0, 100);
    assert(d.update(80, 0, 200).state == GestureState::FLEXION);
  }
  {
    auto d = makeDetector(5000);
    const uint32_t base = UINT32_MAX - 1000;
    arm(d, base - 10);
    d.update(80, 0, base);
    d.update(80, 80, base + 100);
    d.update(80, 0, base + 200);
    assert(d.update(0, 0, base + 5000).event == GestureEvent::SIN_LIBERACION);
  }
  {
    const CalibrationSet up{{500, 3000}, {600, 3200}};
    const CalibrationSet down{{3500, 700}, {3300, 500}};
    assert(calibrationValid(up) && calibrationValid(down));
    assert(normalizeReading(500, up.flex) == 0 &&
           normalizeReading(3000, up.flex) == kAdcMax);
    assert(normalizeReading(3500, down.flex) == 0 &&
           normalizeReading(700, down.flex) == kAdcMax);
    assert(!channelCalibrationValid({100, 299}) &&
           !channelCalibrationValid({-1, 1000}));
    assert(captureStable(490, 510, absoluteSpan(up.flex)));
    assert(!captureStable(400, 1200, absoluteSpan(up.flex)));
    assert(calibrationChecksum(up) != calibrationChecksum(down));
  }
  {
    auto d = makeDetector(5000); arm(d);
    d.update(80, 0, 100); d.update(80, 80, 200); d.update(80, 0, 300);
    assert(d.update(0, 0, 400).repetitions == 1);
    d.update(80, 0, 500); d.update(80, 80, 600);
    d.invalidateAttempt();
    assert(d.update(80, 0, 700).state == GestureState::ESPERA_REPOSO);
    auto r = d.update(0, 0, 800);
    assert(r.event == GestureEvent::NINGUNO && r.repetitions == 1);
    d.update(80, 0, 900); d.update(80, 80, 1000); d.update(80, 0, 1100);
    assert(d.update(0, 0, 1200).repetitions == 2);
  }
  {
    FlexOnlyCounter c(60,35); c.update(80); assert(c.update(0));
    c.update(80); c.invalidateAttempt(); assert(!c.update(80)); assert(!c.update(0)); assert(c.count()==1);
    c.update(80); assert(c.update(0)); assert(c.count()==2);
  }
  {
    assert(!railSuspicious(0, {0, 1200}, true));
    assert(railSuspicious(0, {100, 1200}, true));
    assert(railSuspicious(0, {0, 1200}, false));
    assert(railSuspicious(4095, {0, 1200}, true));
    assert(railSuspicious(0, {0, 0}, true));
    assert(!railSuspicious(1000, {0, 1200}, true));
  }
  std::cout << "17 grupos de pruebas del candidato aprobados\n";
}
