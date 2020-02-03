import 'package:test/test.dart';
import 'package:xstate/xstate.dart';

testAll<T>(Machine machine, Map<T, Map<dynamic, T>> expected) {
  expected.forEach((state, target) {
    target.forEach((event, targetState) {
      final result = machine.transition(state, event).value;
      expect(
        result,
        targetState,
        reason:
            "Transition is [$state---$event--->$result].But it should be [$state---$event--->$targetState]",
      );
    });
  });
}
