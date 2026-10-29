#include <cassert>
#include <iostream>
#include "gesture_logic.h"

GestureDetector makeDetector() { return GestureDetector(60, 35, 60, 35, 3000); }

int main() {
  {
    auto detector = makeDetector();
    detector.update(0, 0, 0);
    detector.update(80, 0, 100);
    detector.update(80, 80, 200);
    detector.update(80, 0, 300);
    const auto result = detector.update(0, 0, 400);
    assert(result.event == GestureEvent::COMPLETA);
    assert(result.repetitions == 1 && result.incomplete == 0);
  }
  {
    auto detector = makeDetector();
    FlexOnlyCounter reference(60, 35);
    reference.update(80);
    detector.update(80, 0, 0);
    assert(reference.update(0));
    const auto result = detector.update(0, 0, 200);
    assert(result.event == GestureEvent::SIN_CONTACTO);
    assert(result.repetitions == 0 && result.incomplete == 1);
    assert(reference.count() == 1);
  }
  {
    auto detector = makeDetector();
    detector.update(0, 80, 0);
    const auto result = detector.update(0, 0, 200);
    assert(result.event == GestureEvent::SIN_FLEXION);
  }
  {
    auto detector = makeDetector();
    detector.update(80, 80, 0);
    const auto timeout = detector.update(80, 80, 3000);
    assert(timeout.event == GestureEvent::SIN_LIBERACION);
    assert(timeout.state == GestureState::ESPERA_REPOSO);
    const auto repeated = detector.update(80, 80, 4000);
    assert(repeated.event == GestureEvent::NINGUNO);
    detector.update(0, 0, 4100);
    const auto recovered = detector.update(0, 0, 4200);
    assert(recovered.state == GestureState::REPOSO);
  }
  {
    auto detector = makeDetector();
    const auto active = detector.update(61, 0, 0);
    assert(active.flexActive);
    const auto heldByHysteresis = detector.update(50, 0, 100);
    assert(heldByHysteresis.flexActive);
    const auto released = detector.update(34, 0, 200);
    assert(!released.flexActive);
  }
  std::cout << "5 pruebas de lógica HandSense aprobadas\n";
}
