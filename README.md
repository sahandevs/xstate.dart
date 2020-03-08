# xstate.dart [![pub package](https://img.shields.io/pub/v/xstate.svg)](https://pub.dev/packages/xstate) ![Dart CI](https://github.com/sahandevs/xstate.dart/workflows/Dart%20CI/badge.svg)
WIP xstate for dart &amp; flutter

### Example
CD Player:

```dart
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

machine.start(); // not_loaded
machine.transition('not_loaded', 'INSERT_CD'); // loaded.stopped
machine.transition('loaded.paused', 'EJECT'); // not_loaded
```

### Roadmap & Features

##### Core

- [x] Core FSM and functions. `machine.start()` , `machine.transition(current, event)` & `state.matches('state')`
- [x] Basic support for Hierarchical or Nested State Machines. `State(child: Machine ...`
- [ ] Complete implementation of Statecharts (guards, context, ...)
- [ ] Parallel State Machines
- [ ] History States
- [ ] Refrence by id. `State(on: {"2": '#B'})`
- [x] `Machine.fromJson({})` ability to create machines with JSON Schema
- [ ] `Machine.fromSCXML('<></>')` ability to create machines with SCXML
- [ ] Binding package for [flutter](https://github.com/flutter/flutter)
- [ ] Binding package for [flutter_hook](https://github.com/rrousselGit/flutter_hooks)
- [ ] Utility package for writing tests
- [ ] More tests


##### Tooling
- [ ] Run a webserver in watch mode and show all the machines in xstatejs's visualizer
###### Dart Analyzer Plugin
- [ ] Show outline for a machine and its states

![image](https://user-images.githubusercontent.com/1113944/74012163-d119a280-499e-11ea-8256-a8ad74b40501.png)

- [ ] __[Quick Fix]__ Convert `Machine.fromJson({})` & `Machine.fromSCXML('<></>')` to `Machine()`
- [ ] __[Quick Fix]__ Convert `Machine()` to `Machine.fromJson({})` or `Machine.fromSCXML('<></>')`
- [ ] __[Diagnostic]__ `machine.maches('state.state_that_doesnt_exists')` validation. (throw state_that_doesnt_exists doesn't exists on the machine)
- [ ] __[Diagnostic]__ Provide warning and errors when creating a machine for invalid transition, invalid paths and unused event and states.
- [ ] __[Quick Fix]__ Extract nested machines.
