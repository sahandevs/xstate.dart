class Machine<TState> {
  final String id;
  final TState initial;
  final Map<TState, State<TState, Object>> states;
  final dynamic history;

  const Machine({
    String id,
    this.initial,
    this.states,
    this.history,
  }) : this.id = id;

  String get describle => "Machine of ${id ?? TState}";
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
  TState value;
  StateValue child;
  StateValue(this.value, [this.child = null]);

  bool matches<MatchPattern>(MatchPattern pattern) {
    if (value == null && pattern == null) return true;
    if (pattern is StateValue) {
      return pattern == this;
    }
    if (pattern is String) {
      return this.describe() == pattern;
    }
    return false;
  }

  String describe() => "$value" + (child == null ? "" : ".${child.describe()}");

  @override
  bool operator ==(o) {
    if (o is TState) return o == value;
    if (o is StateValue) {
      final StateValue _o = o;
      return _o.value == value && _o.child == child;
    }
    return false;
  }
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
    if (child.child != null)
      return StateValue(
        _initial,
        child.child.start(initial: initial.skip(1)),
      );
    return StateValue(_initial);
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
    final states = <TState>[];
    var lastMachine = this;
    var lastState = current;
    while (lastMachine != null) {
      machines.add(lastMachine);
      states.add(lastState.value);
      lastMachine = lastMachine.states[lastState.value].child;
      lastState = lastState.child;
    }
    for (final machine in machines.reversed) {
      final result = machine.states[states.last].on[event];
      if (result != null) {
        final _result = this.start(initial: [result]);
        _result.value = result;
        return _result;
      } else {
        states.removeLast();
      }
    }
    return StateValue(null);
  }
}
