import 'package:test/test.dart';
import 'package:xstate/src/machine.dart';

import 'machine_tester.dart';

main() {
  group('all xstatejs machines are possible in xstate.dart', () {
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
  });
}
