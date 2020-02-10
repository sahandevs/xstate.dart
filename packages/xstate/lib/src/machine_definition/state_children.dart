part of 'machine_definition.dart';

/// A wrapper element containing executable content to be executed when the state is entered.
class OnEntry implements StateChild, ParallelStateChild, FinalStateChild {
  final List<ExecutableContent> children;

  OnEntry({this.children});
}

/// A wrapper element containing executable content to be executed when the state is exited.
class OnExit implements StateChild, ParallelStateChild, FinalStateChild {
  final List<ExecutableContent> children;

  OnExit({this.children});
}

enum TransitionType {
  Internal,
  External,
}

bool _alwaysTrue<T>(T data) => true;

/// Transitions between states are triggered by events and conditionalized via guard conditions.
/// They may contain executable content, which is executed when the transition is taken.
class Transition implements StateChild {
  /// A list of designators of events that trigger this transition.
  final Event event;

  /// The guard condition for this transition.
  ///
  /// defaults to true
  final BooleanExpression cond;

  /// The identifier(s) of the state or parallel region to transition to.
  final IdRef target;

  /// Determines whether the source state is exited in transitions
  /// whose target state is a descendant of the source state.
  ///
  /// default to [TransitionType.External]
  final TransitionType type;

  /// The children of <transition> are executable content that is run after all
  /// the [OnExit] handlers and before the all [OnEntry] handlers that are triggered
  /// by this transition.
  final List<ExecutableContent> children;

  Transition({
    this.event,
    this.cond = _alwaysTrue,
    this.target,
    this.type = TransitionType.External,
    this.children,
  });
}

// TODO: not implemented
class Invoke implements StateChild {}
