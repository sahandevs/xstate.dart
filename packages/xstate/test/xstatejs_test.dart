import 'package:test/test.dart';
import 'package:xstate/src/machine.dart';

import 'machine_tester.dart';

main() {
  group('all xstatejs/test/example machines are possible in xstate.dart', () {
    test('toggle machine', () {
      final machine = Machine(
        id: 'toggle',
        initial: 'inactive',
        states: {
          'inactive': State(on: {'TOGGLE': 'active'}),
          'active': State(on: {'TOGGLE': 'inactive'}),
        },
      );
      testAll(machine, {
        'inactive': {'TOGGLE': 'active'},
        'active': {'TOGGLE': 'inactive'},
      });
    });

    test('CD Player', () {
      const machine = Machine(
        id: 'cd',
        initial: 'not_loaded',
        states: {
          'not_loaded': State(on: {'INSERT_CD': 'loaded'}),
          'loaded': State(
            on: {'EJECT': 'not_loaded'},
            child: Machine(
              initial: 'stopped',
              states: {
                "stopped": State(on: {"PLAY": "playing"}),
                "playing": State(
                  on: {
                    "STOP": "stopped",
                    "EXPIRED_END": "stopped",
                    "EXPIRED_MID": "playing",
                    "PAUSE": "paused"
                  },
                ),
                "paused": State(
                  on: {
                    "PAUSE": "playing",
                    "PLAY": "playing",
                    "STOP": "stopped"
                  },
                  child: Machine(
                    initial: "not_blank",
                    states: {
                      "blank": State(on: {"TIMER": "not_blank"}),
                      "not_blank": State(on: {"TIMER": "blank"})
                    },
                  ),
                )
              },
            ),
          ),
        },
      );

      const expected = {
        "not_loaded": {
          "INSERT_CD": "loaded.stopped",
          'FAKE': null,
        },
        "loaded": {
          "EJECT": "not_loaded",
          'FAKE': null,
        },
        "loaded.stopped": {
          "PLAY": "loaded.playing",
          "EJECT": "not_loaded",
          'FAKE': null,
        },
        "loaded.playing": {
          "EXPIRED_MID": "loaded.playing",
          "EXPIRED_END": "loaded.stopped",
          "STOP": "loaded.stopped",
          "EJECT": "not_loaded",
          "PAUSE": "loaded.paused.not_blank",
          'FAKE': null,
        },
        "loaded.paused": {
          "PAUSE": "loaded.playing",
          "PLAY": "loaded.playing",
          "TIMER": "loaded.paused.blank",
          "EJECT": "not_loaded",
          "STOP": "loaded.stopped",
        },
        "loaded.paused.blank": {
          "PAUSE": "loaded.playing",
          "PLAY": "loaded.playing",
          "TIMER": "loaded.paused.not_blank",
          "EJECT": "not_loaded",
          "STOP": "loaded.stopped",
        }
      };

      testAll(machine, expected);
    });

    test('Example 6.9', () {
      const machine = Machine(
        initial: 'A',
        states: {
          'A': State(
            on: {"6": 'H'},
            child: Machine(
              initial: 'B',
              states: {
                'B': State(
                  on: {"5": 'C'},
                  child: Machine(
                    initial: 'E',
                    states: {
                      'D': State(on: {}),
                      'E': State(on: {"3": 'D'})
                    },
                  ),
                ),
                'C': State(
                  on: {"4": 'B.E'},
                  child: Machine(
                    initial: 'G',
                    states: {
                      'F': State(on: {}),
                      'G': State(on: {"2": 'F'})
                    },
                  ),
                ),
                'hist': State(on: {}, child: Machine(history: true)),
                'deepHist': State(on: {}, child: Machine(history: 'deep')),
              },
            ),
          ),
          'H': State(
            on: {
              "1": 'A.hist',
              "7": 'A.deepHist' // 6.10
            },
          ),
        },
      );

      const expected = {
        "A": {
          "3": "A.B.D",
          "5": "A.C.G",
          "6": "H",
          'FAKE': null,
        },
        "A.B": {
          "3": "A.B.D",
          "5": "A.C.G",
          "6": "H",
          "5, 6, 1": "A.C.G",
          "3, 6, 1": "A.B.E",
          'FAKE': null,
        },
        "A.C": {
          "2": "A.C.F",
          "4": "A.B.E",
          "6": "H",
          "6, 1": "A.C.G",
          "4, 6, 1": "A.B.E",
          'FAKE': null,
        },
        "A.B.D": {
          "5": "A.C.G",
          "6": "H",
          'FAKE': null,
        },
        "A.B.E": {
          "3": "A.B.D",
          "5": "A.C.G",
          "6": "H",
          'FAKE': null,
        },
        "A.C.F": {
          "4": "A.B.E",
          "6": "H",
          'FAKE': null,
        },
        "A.C.G": {
          "2": "A.C.F",
          "4": "A.B.E",
          "6": "H",
          'FAKE': null,
        },
        "H": {
          "1": "A.B.E",
          'FAKE': null,
        }
      };

      testAll(machine, expected);
    });

    test('Example 6.8', () {
      const machine = Machine(initial: 'A', states: {
        'A': State(
          on: {"6": 'F'},
          child: Machine(
            initial: 'B',
            states: {
              'B': State(on: {"1": 'C'}),
              'C': State(on: {"2": 'E'}),
              'D': State(on: {"3": 'B'}),
              'E': State(on: {"4": 'B', "5": 'D'}),
              'hist': State(child: Machine(history: true)),
            },
          ),
        ),
        'F': State(
          on: {"5": 'A.hist'},
        ),
      });

      const expected = {
        "A": {"1": "A.C", "6": "F"},
        "A.B": {"1": "A.C", "6": "F", "FAKE": null},
        "A.C": {"2": "A.E", "6": "F", "FAKE": null},
        "A.D": {"3": "A.B", "6": "F", "FAKE": null},
        "A.E": {"4": "A.B", "5": "A.D", "6": "F", "FAKE": null},
        "F": {"5": "A.B"}
      };
      testAll(machine, expected);
      //  it should respect the history machanism
      final stateC = machine.transition('A.B', '1');
      final stateF = machine.transition(stateC, '6');
      final stateActual = machine.transition(stateF, '5');
      expect(stateActual, equals({'A': 'C'}));
    });

    test('Example 6.6', () {
      const machine = Machine(
        initial: 'A',
        states: {
          'A': State(
            on: {"3": 'B'},
            child: Machine(
              initial: 'D',
              states: {
                'C': State(on: {"2": '#B'}),
                'D': State(on: {"1": 'C'}),
              },
            ),
          ),
          'B': State(
            id: 'B',
            on: {"4": 'A.D'},
          ),
        },
      );

      const expected = {
        'A': {"1": 'A.C', "2": 'A.D', "3": 'B', "4": 'A.D'},
        'B': {"1": 'B', "2": 'B', "3": 'B', "4": 'A.D'},
        'A.C': {"1": 'A.C', "2": 'B', "3": 'B', "4": 'A.C'},
        'A.D': {"1": 'A.C', "2": 'A.D', "3": 'B', "4": 'A.D'}
      };

      testAll(machine, expected);
    });

  });
}
