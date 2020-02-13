part of 'interpreter.dart';

/// Return true if [state] is a compound [State] and one of its children
/// is an active [Final] state (i.e. is a member of the current configuration),
/// or if s is a [Parallel] state and [isInFinalState] is true of all its children.
bool isInFinalState(IState state, InterpreterGlobals globals) {
  if (isCompundState(state))
    return getChildStates(state).any(
      (s) => isInFinalState(s, globals) && globals.configuration.contains(s),
    );
  if (state is Parallel)
    return getChildStates(state).every((s) => isInFinalState(s, globals));

  return false;
}

/// Return the compound [State] such that
/// 1) all states that are exited or entered as a result of taking
///  [transition] are descendants of it
/// 2) no descendant of it has this property.
State getTransitionDomain(Transition transition) {
  final tstates = getEffectiveTargetStates(transition);
  if (tstates.length == 0)
    return null;
  else if (transition.type == TransitionType.Internal &&
      isCompundState(transition.parent) &&
      tstates.every((s) => isDescendant(s, transition.parent))) {
    return transition.parent;
  } else {
    return findLCCA([transition.parent, ...tstates]);
  }
}

/// The Least Common Compound Ancestor is the [State] or [SCXMLRoot] elements
/// such that s is a proper ancestor of all states on [stateList] and no
/// descendant of s has this property. Note that there is guaranteed to be
/// such an element since the [SCXMLRoot] wrapper element is a common ancestor
/// of all states. Note also that since we are speaking of proper ancestor
/// (parent or parent of a parent, etc.) the LCCA is never a member of [stateList].
SCXMLElement findLCCA(Iterable<SCXMLElement> stateList) {
  return getProperAncestors(stateList.first, null)
      .where((x) => (x is State && isCompundState(x)) || x is SCXMLRoot)
      .where((x) => stateList.skip(1).every((s) => isDescendant(s, x)))
      .first;
}

/// Returns the states that will be the target when 'transition' is taken, dereferencing any history states.
LinkedHashSet<IState> getEffectiveTargetStates(Transition transition) {
  final targets = LinkedHashSet<IState>();
  // TODO: support multi targets
  final target = findOneTarget(transition.parent, transition.target);
  // TODO: add support for history valu
  if (target != null) targets.add(target as IState);
  return targets;
}

enum FindTargetSearchType {
  /// starting from siblings then go to the top
  ParentToTop,

  /// start from siblings then go to the bottom
  ParentToBottom,

  /// first take [FindTargetSearchType.ParentToBottom] approach if not found
  /// take [FindTargetSearchType.ParentToTop] approach
  FirstBottomThenTop,

  /// first take [FindTargetSearchType.ParentToTop] approach if not found
  /// take [FindTargetSearchType.ParentToBottom] approach
  FirstTopThenBottom,
}

/// finds target [SCXMLElement] that [target] refres to.
/// [start] is the starting point to the find the target
SCXMLElement findOneTarget(SCXMLElement start, IdRef target,
    {FindTargetSearchType searchType = FindTargetSearchType.ParentToTop}) {
  assert(searchType ==
      FindTargetSearchType.ParentToTop); // TODO: support other methods

  if (start is Identifiable) {
    if (target.isRefersTo(start.id)) return start;
  }

  if (start.parent != null && start.parent is SCXMLElementWithChildren) {
    final _parent = start.parent as SCXMLElementWithChildren;
    var _found = _parent.children
        .whereType<Identifiable>()
        .firstWhere((child) => target.isRefersTo(child.id), orElse: () => null);
    if (_found != null) return _found;
    return findOneTarget(_parent, target);
  }

  return null;
}

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

  if (state1 is StateWithChildren && isDescendant(state2, state1))
    return LinkedHashSet();
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
List<IState> getChildStates(IState state) {
  if (state is StateWithChildren) {
    final _state = state as StateWithChildren;
    return _getStateOrFinalOrParallel(_state.children);
  }
  return const [];
}

List<IState> _getStateOrFinalOrParallel(List children) => children
    .where((item) => item is Parallel || item is State || item is Final)
    .toList();

bool isCompundState(IState state) {
  if (state is StateWithChildren) {
    final _state = state as StateWithChildren;
    return (_state.children?.length ?? 0) > 0;
  }
  return false;
}
