extends Node

## Local typed-by-convention gameplay event stream. Presentation observes events
## but does not own combat, loot, progression, or save decisions.

signal event_emitted(event: Dictionary)

const HISTORY_LIMIT := 128

var _sequence := 0
var _history: Array[Dictionary] = []


func publish(event_type: StringName, payload: Dictionary = {}) -> Dictionary:
	_sequence += 1
	var gameplay_event := {
		"sequence": _sequence,
		"type": String(event_type),
		"payload": payload.duplicate(true),
		"runtime_msec": Time.get_ticks_msec(),
	}
	_history.append(gameplay_event)
	if _history.size() > HISTORY_LIMIT:
		_history.pop_front()
	event_emitted.emit(gameplay_event)
	return gameplay_event


func history() -> Array[Dictionary]:
	return _history.duplicate(true)


func clear_history() -> void:
	_history.clear()
	_sequence = 0
