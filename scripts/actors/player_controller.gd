extends CharacterBody3D

signal attack_started
signal attack_connected(target: Node, damage: int)

const WALK_SPEED := 6.0
const SPRINT_SPEED := 9.0
const JUMP_VELOCITY := 8.5
const ACCELERATION := 28.0
const AIR_ACCELERATION := 9.0
const MOUSE_SENSITIVITY := 0.0022
const STICK_LOOK_SPEED := 2.4
const ATTACK_DAMAGE := 1
const ATTACK_COOLDOWN := 0.45

@onready var visual: Node3D = $Visual
@onready var camera_pivot: Node3D = $CameraPivot
@onready var attack_origin: Marker3D = $AttackOrigin

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 22.0)
var _attack_cooldown_remaining := 0.0


func _ready() -> void:
	add_to_group("player")
	_ensure_input_map()
	if not DisplayServer.get_name().contains("headless"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)
	_update_controller_look(delta)
	if not is_on_floor():
		velocity.y -= _gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var movement_input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var camera_forward := -camera_pivot.global_transform.basis.z
	camera_forward.y = 0.0
	camera_forward = camera_forward.normalized()
	var camera_right := camera_pivot.global_transform.basis.x
	camera_right.y = 0.0
	camera_right = camera_right.normalized()
	var movement_direction := (camera_right * movement_input.x + camera_forward * -movement_input.y).normalized()
	var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
	var target_velocity := movement_direction * speed
	var acceleration := ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
	if movement_direction.length_squared() > 0.01:
		visual.look_at(visual.global_position + movement_direction, Vector3.UP)
	if Input.is_action_just_pressed("attack"):
		_attack()
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		camera_pivot.rotation.x = clampf(
			camera_pivot.rotation.x - event.relative.y * MOUSE_SENSITIVITY,
			-1.05,
			0.55
		)
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func restore_position(saved_position: Array) -> void:
	if saved_position.size() != 3:
		return
	global_position = Vector3(
		float(saved_position[0]),
		float(saved_position[1]),
		float(saved_position[2])
	)
	velocity = Vector3.ZERO


func _attack() -> void:
	if _attack_cooldown_remaining > 0.0:
		return
	_attack_cooldown_remaining = ATTACK_COOLDOWN
	attack_started.emit()
	var shape := SphereShape3D.new()
	shape.radius = 1.35
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, attack_origin.global_position)
	query.collision_mask = 2
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [get_rid()]
	var hits := get_world_3d().direct_space_state.intersect_shape(query, 8)
	var struck := {}
	for hit in hits:
		var target: Node = hit.get("collider")
		if target == null or struck.has(target.get_instance_id()):
			continue
		struck[target.get_instance_id()] = true
		if target.has_method("take_damage"):
			target.call("take_damage", ATTACK_DAMAGE, global_position)
			attack_connected.emit(target, ATTACK_DAMAGE)


func _update_controller_look(delta: float) -> void:
	var look_input := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	if look_input.length_squared() < 0.01:
		return
	camera_pivot.rotation.y -= look_input.x * STICK_LOOK_SPEED * delta
	camera_pivot.rotation.x = clampf(
		camera_pivot.rotation.x - look_input.y * STICK_LOOK_SPEED * delta,
		-1.05,
		0.55
	)


func _ensure_input_map() -> void:
	_bind_key("move_left", KEY_A)
	_bind_key("move_right", KEY_D)
	_bind_key("move_forward", KEY_W)
	_bind_key("move_back", KEY_S)
	_bind_key("jump", KEY_SPACE)
	_bind_key("sprint", KEY_SHIFT)
	_bind_mouse("attack", MOUSE_BUTTON_LEFT)
	_bind_key("attack", KEY_F)
	_bind_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_bind_joy_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	_bind_joy_axis("move_forward", JOY_AXIS_LEFT_Y, -1.0)
	_bind_joy_axis("move_back", JOY_AXIS_LEFT_Y, 1.0)
	_bind_joy_axis("camera_left", JOY_AXIS_RIGHT_X, -1.0)
	_bind_joy_axis("camera_right", JOY_AXIS_RIGHT_X, 1.0)
	_bind_joy_axis("camera_up", JOY_AXIS_RIGHT_Y, -1.0)
	_bind_joy_axis("camera_down", JOY_AXIS_RIGHT_Y, 1.0)
	_bind_joy_button("jump", JOY_BUTTON_A)
	_bind_joy_button("sprint", JOY_BUTTON_LEFT_STICK)
	_bind_joy_button("attack", JOY_BUTTON_RIGHT_SHOULDER)


func _bind_key(action: StringName, keycode: Key) -> void:
	_ensure_action(action)
	var key_event := InputEventKey.new()
	key_event.physical_keycode = keycode
	if not InputMap.action_has_event(action, key_event):
		InputMap.action_add_event(action, key_event)


func _bind_mouse(action: StringName, button_index: MouseButton) -> void:
	_ensure_action(action)
	var mouse_event := InputEventMouseButton.new()
	mouse_event.button_index = button_index
	if not InputMap.action_has_event(action, mouse_event):
		InputMap.action_add_event(action, mouse_event)


func _bind_joy_axis(action: StringName, axis: JoyAxis, axis_value: float) -> void:
	_ensure_action(action)
	var motion_event := InputEventJoypadMotion.new()
	motion_event.axis = axis
	motion_event.axis_value = axis_value
	if not InputMap.action_has_event(action, motion_event):
		InputMap.action_add_event(action, motion_event)


func _bind_joy_button(action: StringName, button_index: JoyButton) -> void:
	_ensure_action(action)
	var button_event := InputEventJoypadButton.new()
	button_event.button_index = button_index
	if not InputMap.action_has_event(action, button_event):
		InputMap.action_add_event(action, button_event)


func _ensure_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)
