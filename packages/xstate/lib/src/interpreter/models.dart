part of 'interpreter.dart';

enum BindingType {
  Early,
  Late,
}

class InterpreterGlobals {
  LinkedHashSet<IState> configuration;
  LinkedHashSet statesToInvoke;
  Queue internalQueue;
  // TODO: must be blocking queue
  Queue externalQueue;
  bool isRunning;
  BindingType binindg;
  HashMap historyValue;
}

class Event {
  final String event;
  final Object data;

  Event(this.event, {this.data});

  Event.done(Id event, {this.data}) : this.event = "done.state.${event.ref}";
}
