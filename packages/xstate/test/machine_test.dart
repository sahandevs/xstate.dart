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
    final machine = Machine(
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

    test(
        'creating machine with values infers the types and constructor doesn\'t throw an error',
        () {
      expect(machine, isNotNull);
      expect(machine.describle, equals("Machine of LightState"));
    });

    test('giving a machine currentState and an event will give the next state',
        () {
      expect(machine.transition(LightState.Green, LightStateEvent.TIMER),
          equals(LightState.Yellow));
      expect(machine.transition(LightState.Yellow, LightStateEvent.TIMER),
          equals(LightState.Red));
      expect(machine.transition(LightState.Red, LightStateEvent.TIMER),
          equals(LightState.Green));
    });

    test('creating a machine with string state works', () {
      final machine = Machine<String>(
        initial: "idle",
        states: {
          "idle": State(
            on: {
              "FETCH": "fetching",
            },
          ),
          "fetching": State(
            on: {
              "RESOLVE": "done",
              "ERROR": "idle",
            },
          ),
          "done": State()
        },
      );

      expect(machine, isNotNull);
      expect(machine.transition("idle", "FETCH"), "fetching");
      expect(machine.transition("fetching", "RESOLVE"), "done");
      expect(machine.transition("fetching", "ERROR"), "idle");
    });
  });
}
