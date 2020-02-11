part of 'interpreter.dart';

enum BindingType {
  Early,
  Later,
}

class InterpreterGlobals {
  LinkedHashSet configuration;
  LinkedHashSet statesToInvoke;
  Queue internalQueue;
  // TODO: must be blocking queue
  Queue externalQueue;
  bool running;
  BindingType binindg;
}
