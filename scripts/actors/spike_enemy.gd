extends CharacterBody3D

signal defeated(enemy_id: StringName, death_position: Vector3)

@export var enemy_id: StringName = &"enemy.spike.gutter_clerk"
@export var max_health := 3
@export var chase_speed := 2.3

@onready var status_label: Label3D = $StatusLabel
@onready var visual: Node3D = $Visual

var _health := 3
var _defeated := false
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 22.0)


func _ready() -> void:
	_health = max_health
	_update_status()


func _physics_process(delta: float) -> void:
	if _defeated:
		return
	if not is_on_floor():
		velocity.y -= _gravity * delta
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player != null:
		var offset := player.global_position - global_position
		offset.y = 0.0
		if offset.length() < 8.0 and offset.length() > 1.7:
			var direction := offset.normalized()
			velocity.x = move_toward(velocity.x, direction.x * chase_speed, 8.0 * delta)
			velocity.z = move_toward(velocity.z, direction.z * chase_speed, 8.0 * delta)
			visual.look_at(visual.global_position + direction, Vector3.UP)
		else:
			velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
	move_and_slide()


func take_damage(amount: int, _source_position: Vector3) -> void:
	if _defeated:
		return
	_health = maxi(0, _health - amount)
	_update_status()
	GameEvents.publish(&"combat.hit", {
		"target_id": String(enemy_id),
		"damage": amount,
		"health_remaining": _health,
	})
	if _health <= 0:
		_defeated = true
		defeated.emit(enemy_id, global_position)
		queue_free()


func _update_status() -> void:
	status_label.text = "GUTTER CLERK  %d/%d" % [_health, max_health]
