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
  final TState value;
  final StateValue child;
  const StateValue(this.value, [this.child = null]);

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

// TODO: needs a rewreite

extension MachineMethods<TState> on Machine<TState> {
  StateValue<TState> start<T>({Iterable<T> initial}) {
    var child = this.states[initial.firstOrNull ?? this.initial];
    if (child.child != null)
      return StateValue(
          this.initial, child.child.start(initial: initial.skip(1)));
    return StateValue(this.initial);
  }

  StateValue<TState> transition<TEvent, TCurrent>(
      TCurrent current, TEvent event) {
    State state;
    List<String> _currentPath;
    if (current is StateValue) {
      state = this.states[current.value];
    } else if (current is String) {
      final String _current = current;
      _currentPath = _current.split('.');
      state = this.states[_currentPath.first];
      if (_currentPath.length > 1) {
        final childStateValue = state.child.transition(
            state.child.start(initial: _currentPath.skip(1)), event);
        if (childStateValue.value == null) {
          // child didn't have the event
          final _value = state.on[event]; // check if parent can handle it
          if (_value == null) return StateValue(null);
          return StateValue(_value);
        }
        return StateValue(_currentPath.first as TState, childStateValue);
      }
    } else {
      state = this.states[current];
    }
    final targetStateValue = state.on[event];
    if (targetStateValue == null) return StateValue(null);
    // check if targetState has child
    final targetState = this.states[targetStateValue];
    if (targetState.child != null)
      return StateValue(targetStateValue,
          targetState.child.start(initial: _currentPath.skip(1)));

    return StateValue(targetStateValue);
  }
}
