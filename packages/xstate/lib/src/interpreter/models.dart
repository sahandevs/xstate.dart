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
  HashMap<Id, LinkedHashSet<IState>> historyValue;
}

