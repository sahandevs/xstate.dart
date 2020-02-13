part of 'machine_definition.dart';

// marker interface
abstract class SCXMLElement {
  SCXMLElement parent = null;
}

abstract class SCXMLElementWithChildren<T> extends SCXMLElement {
  List<T> get children;
}

// marker interface
abstract class SCXMLChild implements SCXMLElement {}

/// The top-level wrapper element, which carries 
/// The actual state machine consists of its children.
/// 
/// Note that only one of the children is active at any one time.
/// See [3.11 Legal State Configurations and Specifications](https://www.w3.org/TR/scxml/#LegalStateConfigurations) 
/// for details.
class SCXMLRoot implements SCXMLElement {
  /// The id of the initial state(s) for the document.
  /// If not specified, the default initial state is the first child state in document order.
  final IdRef initial;

  /// The name of this state machine.
  /// It is for purely informational purposes.
  final String name;

  final List<SCXMLChild> children;

  // TODO(sahandevs): add datamodel

  // TODO(sahandevs): add binding

  SCXMLRoot({IdRef initial, this.name, this.children})
      : initial = initial ?? children.whereType<State>().first {
        children.forEach((child) => child.parent = this);
      }

  @override
  SCXMLElement parent = null;
}
