part of 'machine.dart';

State<String, String> _toState(Map data) {
  Machine child;
  if (data.containsKey("initial")) {
    child = _toMachine(data);
  }
  final state = State<String, String>(
    child: child,
    on: data["on"],
  );
  return state;
}

Machine _toMachine(Map data) {
  final Map<String, State<String, String>> _states = {};
  (data["states"] as Map<String, Map>)
      .forEach((key, value) => _states[key] = _toState(value));
  final machine = Machine<String>(
    id: data["id"],
    initial: data["initial"],
    states: _states,
  );
  return machine;
}

Machine buildMachineFromJson(Map data) => _toMachine(data);

Map _stateToJson(State value) {
  final Map<String, dynamic> result = {};

  result["id"] = value.id;
  result["on"] = value.on;
  if (value.child != null) {
    result.addAll(machineToJson(value.child));
  }
  return result;
}

Map _statseToJson(Map<dynamic, State> value) {
  final Map<String, dynamic> result = {};
  value.forEach((key, value) => result[key] = _stateToJson(value));
  return result;
}

Map machineToJson(Machine machine) {
  final Map<String, dynamic> result = {};
  result["id"] = machine.id;
  result["initial"] = machine.initial;
  result["states"] = _statseToJson(machine.states);
  return result;
}
