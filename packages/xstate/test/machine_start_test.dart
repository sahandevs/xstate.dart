import 'package:test/test.dart';
import 'package:xstate/src/machine.dart';

main() {
  group('test machine.start method', () {
    test(
        'starting a machine without nested machines will create a correct StateValue',
        () {
      const machine = Machine(
        initial: "A",
        states: {
          "A": State(on: {}),
          "B": State(on: {}),
        },
      );
      expect(machine.start(initial: ["A"]).describe(), "A");
      expect(machine.start(initial: []).describe(), "A");
      expect(machine.start(initial: ["B"]).describe(), "B");
    });

    test(
        'starting a machine with one nested machine will create a correct StateValue',
        () {
      const machine = Machine(
        initial: "A",
        states: {
          "A": State(
            on: {},
            child: Machine(
              initial: "[A]A",
              states: {
                "[A]A": State(on: {}),
                "[A]B": State(on: {}),
              },
            ),
          ),
          "B": State(on: {}),
        },
      );

      expect(machine.start(initial: ["B"]).describe(), "B");
      expect(machine.start(initial: ["A"]).describe(), "A.[A]A");
      expect(machine.start(initial: []).describe(), "A.[A]A");
      expect(machine.start(initial: "A.[A]A".split(".")).describe(), "A.[A]A");
      expect(machine.start(initial: "A.[A]B".split(".")).describe(), "A.[A]B");
    });

    test(
        'starting a machine with deeply nested machine will create a correct StateValue',
        () {
      const machine = Machine(
        initial: "not_loaded",
        states: {
          "loaded": State(
            on: {},
            child: Machine(
              initial: "stopped",
              states: {
                "stopped": State(on: {}),
                "paused": State(
                  on: {},
                  child: Machine(
                    initial: "not_blank",
                    states: {
                      "not_blank": State(on: {}),
                      "blank": State(on: {}),
                    },
                  ),
                ),
                "nested": State(
                  on: {},
                  child: Machine(
                    initial: "d1",
                    states: {
                      "d1": State(
                        on: {},
                        child: Machine(
                          initial: "d2",
                          states: {
                            "d2": State(on: {}),
                          },
                        ),
                      ),
                    },
                  ),
                ),
              },
            ),
          ),
          "not_loaded": State(on: {}),
        },
      );

      expect(machine.start(initial: []).describe(), "not_loaded");
      expect(machine.start(initial: ["not_loaded"]).describe(), "not_loaded");
      expect(machine.start(initial: "loaded".split(".")).describe(), "loaded.stopped");
      expect(machine.start(initial: "loaded.stopped".split(".")).describe(), "loaded.stopped");
      expect(machine.start(initial: "loaded.paused".split(".")).describe(), "loaded.paused.not_blank");
      expect(machine.start(initial: "loaded.paused.not_blank".split(".")).describe(), "loaded.paused.not_blank");
      expect(machine.start(initial: "loaded.paused.blank".split(".")).describe(), "loaded.paused.blank");
      expect(machine.start(initial: "loaded.nested".split(".")).describe(), "loaded.nested.d1.d2");
      expect(machine.start(initial: "loaded.nested.d1".split(".")).describe(), "loaded.nested.d1.d2");
      expect(machine.start(initial: "loaded.nested.d1.d2".split(".")).describe(), "loaded.nested.d1.d2");
    });
  });
}
