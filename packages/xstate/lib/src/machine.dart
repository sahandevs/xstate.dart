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
  const StateValue(this.value);

  @override
  bool operator ==(o) => o is TState && o == value;
}

extension MachineMethods<TState> on Machine<TState> {
  StateValue<TState> transition<TEvent, TCurrent>(
      TCurrent current, TEvent event) {
    TState result;
    if (current is StateValue) {
      result = this.states[current.value].on[event];
    } else {
      result = this.states[current].on[event];
    }
    return StateValue(result);
  }
}
