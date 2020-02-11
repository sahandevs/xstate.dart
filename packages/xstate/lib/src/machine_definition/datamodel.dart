part of 'machine_definition.dart';

// marker interface
abstract class DataModelChild {}

/// [DataModel] is a wrapper element which encapsulates any number of [DataModelChild] elements,
/// each of which defines a single [Data] object. The exact nature of the data object depends on
/// the data model language used.
class DataModel implements SCXMLChild {
  final List<DataModelChild> children;

  DataModel({this.children = const []});

  @override
  SCXMLElement parent;
}
