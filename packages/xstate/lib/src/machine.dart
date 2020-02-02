class Machine<TState> {
  
  const Machine({
    TState initial,
    Map<TState, State<TState, dynamic>> states,
  });

  String get describle => "Machine of ${TState}";

}

class State<TState, TEvent> {
  const State({
    Map<TEvent, TState> on,
  });
}
