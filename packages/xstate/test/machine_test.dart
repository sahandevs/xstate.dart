import 'package:xstate/xstate.dart';
import 'package:test/test.dart';

enum LightState {
  Green,
  Yellow,
  Red,
}

enum LightStateEvent { TIMER }

void main() {
  group('creating machine', () {
    test(
        'creating machine with values infers the types and constructor doesn\'t throw an error',
        () {
      var machine = Machine(
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
      expect(machine.describle, equals("Machine of LightState"));
      expect(machine, isNotNull);
    });
  });
}
