import 'package:xstate/xstate.dart';
import 'package:test/test.dart';

enum LightState {
  Green,
  Yellow,
  Red,
}

enum LightStateEvent { TIMER }

Machine createMachine() => Machine(
      initial: LightState.Green,
      states: {
        LightState.Green: State(
          on: {
            LightStateEvent.TIMER: LightState.Yellow,
          },
        ),
        LightState.Yellow: State(
          on: {
            LightStateEvent.TIMER: LightState.Red,
          },
        ),
        LightState.Red: State(
          on: {
            LightStateEvent.TIMER: LightState.Green,
          },
        )
      },
    );

void main() {
  group('creating machine', () {
    test(
        'creating machine with values infers the types and constructor doesn\'t throw an error',
        () {
      final machine = createMachine();
      expect(machine, isNotNull);
      expect(machine.describle, equals("Machine of LightState"));
    });

    test('giving a machine currentState and an event will give the next state', () {
      final machine = createMachine();
      expect(machine.transition(LightState.Green, LightStateEvent.TIMER), equals(LightState.Yellow));
      expect(machine.transition(LightState.Yellow, LightStateEvent.TIMER), equals(LightState.Red));
      expect(machine.transition(LightState.Red, LightStateEvent.TIMER), equals(LightState.Green));
    });
  });
}
