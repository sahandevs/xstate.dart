part of 'interpreter.dart';

/// If [state2] is null, returns the set of all ancestors of [state1] in ancestry order
/// ([state1]'s parent followed by the parent's parent, etc. up to an including the <scxml> element).
/// If [state2] is non-null, returns in ancestry order the set of all ancestors of [state1], up to but
/// not including [state2]. (A "proper ancestor" of a state is its parent, or the parent's parent, or
/// the parent's parent's parent, etc.))If [state2] is [state1]'s parent, or equal to [state1], or a descendant
/// of [state1], this returns the empty set.
LinkedHashSet<SCXMLElement> getProperAncestors(
    SCXMLElement state1, SCXMLElement state2) {
  assert(state1 != null && state1 is IState);
  assert(state2 == null || state2 is IState);

  if (state1 == state2 || state1.parent == state2) return LinkedHashSet();

  if (state1 is StateWithChildren) if (isDescendant(
      state2, state1 as StateWithChildren)) return LinkedHashSet();
  // TODO: what should happen when [state2] is not proper ancestor of state1 ?
  final result = LinkedHashSet<SCXMLElement>();
  if (state1.parent == null) return result;
  result.add(state1.parent);
  result.addAll(getProperAncestors(state1.parent, state2));
  return result;
}

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
