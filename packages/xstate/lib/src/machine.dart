class Machine<TState> {
  final TState initial;
  final Map<TState, State<TState, Object>> states;

  const Machine({
    this.initial,
    this.states,
  });

  String get describle => "Machine of ${TState}";
}

class State<TState, TEvent> {
  final Map<TEvent, TState> on;
  const State({
    this.on,
  });
}

extension MachineMethods<TState> on Machine<TState> {
  TState transition<TEvent>(TState current, TEvent event) =>
      this.states[current].on[event];
}
