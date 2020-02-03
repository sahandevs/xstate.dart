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

extension MachineMethods<TState> on Machine<TState> {
  TState transition<TEvent>(TState current, TEvent event) =>
      this.states[current].on[event];
}
