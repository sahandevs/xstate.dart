import 'dart:collection';
import 'dart:isolate';

import 'package:xstate/src/machine_definition/machine_definition.dart';

part 'models.dart';
part 'helpers.dart';

class Interpreter {
  final SCXMLRoot document;

  Interpreter(this.document);

  interpret() {
    final globals = InterpreterGlobals();
    globals.configuration = LinkedHashSet();
    globals.statesToInvoke = LinkedHashSet();
    globals.internalQueue = Queue();
    globals.externalQueue = Queue();
    globals.historyValue = HashMap();
    // TODO: setup datamodel
    globals.isRunning = true;
    enterStates(
        [document.children.whereType<Initial>().first.transition], globals);
    Isolate.spawn((_) {
      mainEventLoop(globals);
    }, null);
  }
}
