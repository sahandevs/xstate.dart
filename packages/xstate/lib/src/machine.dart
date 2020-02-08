import 'dart:convert';

part 'machine_json.dart';

class Machine<TState> {
  final String id;
  final TState initial;
  final Map<TState, State<TState, Object>> states;
  final dynamic history;

  factory Machine.fromJson(Map data)
    => buildMachineFromJson(data);

  const Machine({
    String id,
    this.initial,
    this.states,
    this.history,
  }) : this.id = id;

  String get describle => "Machine of ${id ?? TState}";
  String get json => jsonEncode(machineToJson(this));
}

class State<TState, TEvent> {
  final Map<TEvent, TState> on;
  final Machine child;
  final String id;

  const State({
    this.id,
    this.on,
    this.child,
  });
}

class StateValue<TState> {
  List<TState> value;
  StateValue([this.value = const []]);
  StateValue.leaf(TState top) : this.value = [top];

  bool matches<MatchPattern>(MatchPattern pattern) {
    if (value[0] == null && pattern == null) return true;
    // if (pattern is StateValue) {
    //   return pattern == this;
    // }
    if (pattern is String) {
      return this.describe().startsWith(pattern);
    }
    return false;
  }

  String describe() => value.join(".");
}

extension<T> on Iterable<T> {
  T get firstOrNull {
    try {
      return this.first;
    } catch (_) {
      return null;
    }
  }
}

extension MachineMethods<TState> on Machine<TState> {
  StateValue<TState> start<T>({Iterable<T> initial}) {
    final _initial = initial.firstOrNull ?? this.initial;
    var child = this.states[_initial];
    if (child == null)
      throw new Exception(
          "state '$_initial' not found on [${this.describle} ${this.states.keys}]");
    if (child.child != null)
      return StateValue([
        _initial,
        ...child.child.start(initial: initial.skip(1)).value,
      ]);
    return StateValue.leaf(_initial);
  }

  StateValue<TState> transition<TEvent, TCurrent>(
      TCurrent current, TEvent event) {
    final valueState = current as String;
    assert(valueState != null);

    final _path = valueState.split(".");
    final _current = this.start(initial: _path);

    return _handleEvent(_current, event);
  }

  StateValue _handleEvent<T, TState>(StateValue<TState> current, T event) {
    // start from the bottom
    final machines = <Machine>[];
    final states = <TState>[...current.value];
    var lastMachine = this;
    var lastState = 0;
    while (lastMachine != null) {
      machines.add(lastMachine);
      lastMachine = lastMachine.states[states[lastState]].child;
      lastState++;
    }
    for (final machine in machines.reversed) {
      final result = machine.states[states.last].on[event];
      if (result != null) {
        final _result = machine.start(initial: [result]);
        states.removeLast();
        states.addAll(_result.value as List<TState>);
        return StateValue(states);
      } else {
        states.removeLast();
      }
    }
    return StateValue.leaf(null);
  }
}
