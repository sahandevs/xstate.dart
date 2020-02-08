import 'package:test/test.dart';

import 'package:xstate/xstate.dart';
import 'machine_tester.dart';

main() {
  test(
      'machine.fromJson with simple machine without nested machines produces a correct machine',
      () {
    final machine = Machine.fromJson({
      "key": "cd",
      "initial": "not_loaded",
      "states": {
        "not_loaded": {
          "on": {"INSERT_CD": "loaded"}
        },
        "loaded": {
          "on": {"EJECT": "not_loaded"}
        }
      }
    });

    const expected = {
      "not_loaded": {
        "INSERT_CD": "loaded",
        'FAKE': null,
      },
      "loaded": {
        "EJECT": "not_loaded",
        'FAKE': null,
      }
    };

    testAll(machine, expected);
  });

  test(
      'machine.fromJson with simple machine with nested machines produces a correct machine',
      () {
    final machine = Machine.fromJson({
      "key": "cd",
      "initial": "not_loaded",
      "states": {
        "not_loaded": {
          "on": {"INSERT_CD": "loaded"}
        },
        "loaded": {
          "initial": "stopped",
          "on": {"EJECT": "not_loaded"},
          "states": {
            "stopped": {
              "on": {"PLAY": "playing"}
            },
            "playing": {
              "on": {
                "STOP": "stopped",
                "EXPIRED_END": "stopped",
                "EXPIRED_MID": "playing",
                "PAUSE": "paused"
              }
            },
            "paused": {
              "initial": "not_blank",
              "states": {
                "blank": {
                  "on": {"TIMER": "not_blank"}
                },
                "not_blank": {
                  "on": {"TIMER": "blank"}
                }
              },
              "on": {"PAUSE": "playing", "PLAY": "playing", "STOP": "stopped"}
            }
          }
        }
      }
    });

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

  test(
      'calling machine.fromJson with invalid json will raise a validation error',
      () {
    // TODO(sahandevs)
  });

  // TODO(sahandevs): add tests for machineToJson
}
