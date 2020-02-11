part of 'interpreter.dart';



/// Returns 'true' if [state] is a descendant of [parent]
/// (a child, or a child of a child, or a child of a child of a child, etc.)
/// Otherwise returns 'false'.
bool isDescendant(IState state, StateWithChildren parent) =>
    parent.children.any((child) {
      if (child == state) return true;
      if (child is StateWithChildren) return isDescendant(state, child);
      return false;
    });

/// Returns a list containing all [State], [Final], and [Paralel] children of [state].
List<IState> getChildStates<T>(StateWithChildren<T> state) =>
    _getStateOrFinalOrParallel(state.children);

List<IState> _getStateOrFinalOrParallel(List children) => children
    .where((item) => item is Parallel || item is State || item is Final)
    .toList();
