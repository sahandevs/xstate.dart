part of 'machine_definition.dart';

class IdRef {
  final String ref;
  const IdRef(this.ref);

  bool isRefersTo(Id target) {
    return target.ref == ref;
  }

}

abstract class Identifiable implements SCXMLElement {
  Id get id;
}

class Id {
  final String ref;
  const Id(this.ref);
}

class Event {
  final String name;
  const Event(this.name);
}


typedef bool BooleanExpression<T>(T context);