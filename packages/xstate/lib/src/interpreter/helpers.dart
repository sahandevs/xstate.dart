part of 'interpreter.dart';

/// For each transition t in enabledTransitions,if t is targetless then do nothing, else compute
/// the transition's domain. (This will be the source state in the case of internal transitions)
/// or the least common compound ancestor state of the source state and target states of t
/// (in the case of external transitions. Add to the statesToExit set all states in the configuration
/// that are descendants of the domain.
LinkedHashSet<IState> computeExitSet(
  List<Transition> enabledTransitions,
  InterpreterGlobals globals,
) {
  final statesToExit = LinkedHashSet<IState>();
  enabledTransitions.forEach((transition) {
    // TODO: add support for multi target
    final target = findOneTarget(transition, transition.target);
    if (target != null) {
      final domain = getTransitionDomain(transition);
      globals.configuration
          .where((s) => isDescendant(s, domain))
          .forEach((s) => statesToExit.add(s));
    }
  });
  return statesToExit;
}

/// For each transition in the list of enabledTransitions, execute its executable content.
void executeTransitionContent(List<Transition> enabledTransitions) {
  // TODO: not implemnted
}

/// First, compute the list of all the states that will be entered as a result of taking the
/// transitions in [enabledTransitions]. Add them to statesToInvoke so that invoke processing
/// can be done at the start of the next macrostep. Convert statesToEnter to a list and sort
/// it in entryOrder. For each state s in the list, first add s to the current configuration.
/// Then if we are using late binding, and this is the first time we have entered s, initialize its data model.
/// Then execute any onentry handlers. If s's initial state is being entered by default, execute any
/// executable content in the initial transition. If a history state in s was the target of a transition,
/// and s has not been entered before, execute the content inside the history state's default transition.
/// Finally, if s is a final state, generate relevant Done events. If we have reached a top-level final state,
/// set running to false as a signal to stop processing.
void enterStates(
  List<Transition> enabledTransitions,
  InterpreterGlobals globals,
) {
  final statesToEnter = LinkedHashSet<IState>();
  final statesForDefaultEntry = LinkedHashSet();
  // initialize the temporary table for default content in history states
  final defaultHistoryContent = HashMap();
  computeEntrySet(
    enabledTransitions,
    statesToEnter,
    statesForDefaultEntry,
    defaultHistoryContent,
    globals,
  );
  statesToEnter // TODO: add support for entryOrder
      .forEach((s) {
    globals.configuration.add(s);
    globals.statesToInvoke.add(s);
    if (globals.binindg == BindingType.Late && s.isFirstEntry) {
      // initializeDataModel(datamodel.s,doc.s)
      s.isFirstEntry = false;
    }
    // TODO: execute content
    if (s is Final) {
      if (s.parent is SCXMLRoot) {
        globals.isRunning = false;
      } else {
        final parent = s.parent as IState;
        final grandParent = parent.parent;
        globals.internalQueue.add(
          Event.done(parent.id, data: null /* TODO: s.doneData */),
        );
        if (grandParent is Parallel) {
          if (getChildStates(grandParent)
              .every((s) => isInFinalState(s, globals))) {
            globals.internalQueue.add(Event.done(grandParent.id));
          }
        }
      }
    }
  });
}

/// Compute the complete set of states that will be entered as a result of taking
/// [transitions]. This value will be returned in [statesToEnter] (which is modified by this procedure).
///  Also place in [statesForDefaultEntry] the set of all states whose default initial states were entered.
///  First gather up all the target states in [transitions]. Then add them and, for all that are not
/// atomic states, add all of their (default) descendants until we reach one or more atomic states.
/// Then add any ancestors that will be entered within the domain of the transition.
/// (Ancestors outside of the domain of the transition will not have been exited.)
void computeEntrySet(
  List<Transition> transitions,
  LinkedHashSet statesToEnter,
  LinkedHashSet statesForDefaultEntry,
  HashMap defaultHistoryContent,
  InterpreterGlobals globals,
) {
  transitions.forEach((transition) {
    // TODO: support multi target
    final target = findOneTarget(transition, transition.target);
    addDescendantStatesToEnter(
      target,
      statesToEnter,
      statesForDefaultEntry,
      defaultHistoryContent,
      globals,
    );
    final ancestor = getTransitionDomain(transition);
    getEffectiveTargetStates(transition).forEach(
      (s) => addAncestorStatesToEnter(
        s,
        ancestor,
        statesToEnter,
        statesForDefaultEntry,
        defaultHistoryContent,
      ),
    );
  });
}

/// The purpose of this procedure is to add to statesToEnter [state] and any of its descendants
/// that the state machine will end up entering when it enters [state].
/// (N.B. If [state] is a history pseudo-state, we dereference it and add the history value instead.)
/// Note that this procedure permanently modifies both statesToEnter and statesForDefaultEntry.
///
/// First, If state is a history state then add either the history values associated with state or
/// state's default target to statesToEnter. Then (since the history value may not be an immediate
/// descendant of [state]s parent) add any ancestors between the history value and state's parent.
/// Else (if state is not a history state), add state to statesToEnter. Then if state is a compound state,
/// add state to [statesForDefaultEntry] and recursively call [addStatesToEnter] on its default initial state(s).
/// Then, since the default initial states may not be children of [state], add any ancestors between
/// the default initial states and [state]. Otherwise, if state is a parallel state, recursively call
/// [addStatesToEnter] on any of its child states that don't already have a descendant on statesToEnter.
void addDescendantStatesToEnter(
  IState state,
  LinkedHashSet statesToEnter,
  LinkedHashSet statesForDefaultEntry,
  HashMap defaultHistoryContent,
  InterpreterGlobals globals,
) {
  if (state is History) {
    if (globals.historyValue.containsKey(state.id)) {
      final _states = globals.historyValue[state.id] as Iterable<IState>;
      _states.forEach(
        (s) => addDescendantStatesToEnter(
          s,
          statesToEnter,
          statesForDefaultEntry,
          defaultHistoryContent,
          globals,
        ),
      );
      // TODO: we may need get globals.historyValue[state.id] again
      _states.forEach(
        (s) => addAncestorStatesToEnter(
          s,
          state.parent,
          statesToEnter,
          statesForDefaultEntry,
          defaultHistoryContent,
        ),
      );
    }
  } else {
    statesToEnter.add(state);
    if (isCompundState(state)) {
      statesForDefaultEntry.add(state);
      // TODO: add support for multi target
      final _initial = getInitialState(state);
      final _target = findOneTarget(_initial, _initial.transition.target);
      addDescendantStatesToEnter(
        _target,
        statesToEnter,
        statesForDefaultEntry,
        defaultHistoryContent,
        globals,
      );
      // TODO: we may need to get the _target again
      addAncestorStatesToEnter(
        _target,
        state,
        statesToEnter,
        statesForDefaultEntry,
        defaultHistoryContent,
      );
    } else {
      if (state is Parallel) {
        getChildStates(state)
            .where((child) => !statesToEnter.any((s) => isDescendant(s, child)))
            .forEach(
              (child) => addDescendantStatesToEnter(
                child,
                statesToEnter,
                statesForDefaultEntry,
                defaultHistoryContent,
                globals,
              ),
            );
      }
    }
  }
}

/// returns initial state of a compound state
Initial getInitialState(IState state) {
  if (state is StateWithChildren) {
    final _state = state as StateWithChildren;
    return _state.children.whereType<Initial>().first;
  }
  return null;
}

/// Add to [statesToEnter] any ancestors of [state] up to, but not including,
/// [ancestor] that must be entered in order to enter [state]. If any of these
/// ancestor states is a [Parallel] state, we must fill in its descendants as well.
void addAncestorStatesToEnter(
  IState state,
  SCXMLElement ancestor,
  LinkedHashSet statesToEnter,
  LinkedHashSet statesForDefaultEntry,
  HashMap defaultHistoryContent,
) {
  getProperAncestors(state, ancestor).forEach((anc) {
    statesToEnter.add(anc);
    if (anc is Parallel) {
      getChildStates(anc)
          .where((child) => !statesToEnter.any((s) => isDescendant(s, child)))
          .forEach((child) {
        // TODO: addDescendantStatesToEnter(child,statesToEnter,statesForDefaultEntry, defaultHistoryContent)
      });
    }
  });
}

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

  if (isDescendant(state2, state1)) return LinkedHashSet();
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
bool isDescendant(IState state, IState parent) {
  if (parent is StateWithChildren) {
    final _parent = parent as StateWithChildren;
    return _parent.children.any((child) {
      if (child == state) return true;
      return isDescendant(state, child);
    });
  }
  return false;
}

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
