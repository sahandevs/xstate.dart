part of 'machine_definition.dart';

abstract class IState implements SCXMLChild {
  /// The identifier for this state.
  final Id id;

  IState(this.id);

  IState._(this.id);
}

abstract class StateWithChildren<T> {
  List<T> get children;
}

// marker interface
abstract class StateChild {}

/// Holds the representation of a [State].
class State extends IState implements StateWithChildren<StateChild> {
  /// The id of the default initial state (or states) for this state.
  ///
  /// TODO: MUST NOT be specified in conjunction with the <initial> element. MUST NOT occur in atomic states.
  final IdRef initial;

  final List<StateChild> children;

  bool get isCompuned => (children?.length ?? 0) > 0;

  State({Id id, this.initial, this.children}) : super(id);
}

// marker interface
abstract class ParallelStateChild {}

/// The [Parallel] element encapsulates a set of child states which
/// are simultaneously active when the parent element is active.
class Parallel extends IState implements StateWithChildren<ParallelStateChild> {
  final List<ParallelStateChild> children;

  Parallel({Id id, this.children}) : super(id);
}

// marker interface
abstract class FinalStateChild {}

/// [Final] represents a final state of an [SCXML] or compound [State] element.
class Final extends IState implements StateWithChildren<FinalStateChild> {
  final List<FinalStateChild> children;

  Final({Id id, this.children}) : super(id);
}

class History extends IState {

  /// A [Transition] whose [Transition.target] specifies the default history configuration.
  /// Occurs once. In a conformant SCXML document,
  /// this transition must not contain 'cond' or 'event' attributes,
  /// and must specify a non-null 'target' whose value is a valid state specification.
  final List<Transition> children;

  History({Id id, this.children}) : super(id);
}
