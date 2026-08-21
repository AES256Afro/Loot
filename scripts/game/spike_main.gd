extends Node3D

const ENEMY_SCENE := preload("res://scenes/actors/spike_enemy.tscn")
const RUN_SEED := 20_260_820

@onready var player: CharacterBody3D = $Player
@onready var enemy: CharacterBody3D = $SpikeEnemy
@onready var objective_label: Label = $HUD/Objective
@onready var event_feed: RichTextLabel = $HUD/EventFeed
@onready var save_status: Label = $HUD/SaveStatus

var _reward_resolver := DeterministicRewardResolver.new()
var _inventory: Array[String] = []
var _feed_lines: Array[String] = []
var _reward_roll_index := 0
var _defeat_count := 0


func _ready() -> void:
	_build_graybox()
	if not Content.load_all():
		for content_error in Content.last_errors:
			push_error(content_error)
		objective_label.text = "CONTENT ERROR. Run tools/check.sh for details."
	else:
		objective_label.text = "M00 TEST ANNEX  |  Defeat the Gutter Clerk  |  Loot: 0"
	_connect_enemy(enemy)
	player.attack_started.connect(_on_player_attack_started)
	player.attack_connected.connect(_on_player_attack_connected)
	_push_line("HERALD", "A Claimant has entered the testing annex. The annex has waived responsibility preemptively.")
	_push_line("PICKET", "The annex is not authorized to waive structural responsibility.")
	GameEvents.publish(&"zone.entered", {"zone_id": "zone.spike.test_annex"})


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_F5:
			_save_profile(false)
		KEY_F9:
			_load_profile()
		KEY_R:
			if not is_instance_valid(enemy):
				_spawn_enemy()


func _connect_enemy(target: Node) -> void:
	if target != null and target.has_signal("defeated"):
		target.defeated.connect(_on_enemy_defeated)


func _on_player_attack_started() -> void:
	save_status.text = "ATTACK: Compliance tap issued."


func _on_player_attack_connected(target: Node, damage: int) -> void:
	save_status.text = "HIT: %s took %d damage." % [target.name, damage]


func _on_enemy_defeated(enemy_id: StringName, death_position: Vector3) -> void:
	_defeat_count += 1
	GameEvents.publish(&"combat.enemy_defeated", {
		"enemy_id": String(enemy_id),
		"defeat_count": _defeat_count,
	})
	var reward := _reward_resolver.roll_item(Content.all_items(), RUN_SEED, _reward_roll_index)
	_reward_roll_index += 1
	if reward.is_empty():
		_push_line("PICKET", "The reward ledger is empty. This is both unusual and, somehow, familiar.")
		return
	var item_id := String(reward["id"])
	_inventory.append(item_id)
	_spawn_reward_display(reward, death_position)
	_push_line("HERALD", "The Clerk has been removed from office by repeated informal striking.")
	_push_line("LOOT", "%s [%s]\n%s" % [
		String(reward["display_name"]),
		String(reward["rarity"]).to_upper(),
		String(reward["description"]),
	])
	objective_label.text = "ANNEX CLEARED  |  Press R to restaff it  |  Loot: %d" % _inventory.size()
	GameEvents.publish(&"reward.granted", {
		"item_id": item_id,
		"source_id": String(enemy_id),
		"baseline_reward": true,
	})
	_save_profile(true)


func _spawn_enemy() -> void:
	enemy = ENEMY_SCENE.instantiate()
	enemy.position = Vector3(0.0, 0.1, -4.0)
	add_child(enemy)
	_connect_enemy(enemy)
	objective_label.text = "M00 TEST ANNEX  |  Defeat the replacement Gutter Clerk  |  Loot: %d" % _inventory.size()
	_push_line("PICKET", "Replacement clerk installed. The hiring process was a trapdoor.")


func _save_profile(automatic: bool) -> void:
	var position := player.global_position
	var profile := {
		"player": {"position": [position.x, position.y, position.z]},
		"run": {
			"seed": RUN_SEED,
			"reward_roll_index": _reward_roll_index,
			"defeat_count": _defeat_count,
		},
		"inventory": _inventory.duplicate(),
	}
	var result := Saves.write_atomic(profile)
	if result.get("ok", false):
		save_status.text = "AUTOSAVED: Atomic profile commit passed." if automatic else "SAVED: Atomic profile commit passed."
	else:
		save_status.text = "SAVE FAILED: %s" % result.get("message", "Unknown error")
		push_error(save_status.text)


func _load_profile() -> void:
	var result := Saves.load_profile()
	if not result.get("ok", false):
		save_status.text = "LOAD: No valid spike save yet."
		return
	var data: Dictionary = result.get("data", {})
	var player_data: Dictionary = data.get("player", {})
	player.call("restore_position", player_data.get("position", []))
	var run_data: Dictionary = data.get("run", {})
	_reward_roll_index = int(run_data.get("reward_roll_index", 0))
	_defeat_count = int(run_data.get("defeat_count", 0))
	_inventory.clear()
	for item_id in data.get("inventory", []):
		_inventory.append(String(item_id))
	objective_label.text = "PROFILE RESTORED  |  Loot: %d  |  Defeats: %d" % [_inventory.size(), _defeat_count]
	save_status.text = "LOADED: %s" % (
		"Backup recovered." if result.get("recovered_from_backup", false) else "Primary profile verified."
	)


func _push_line(speaker: String, line: String) -> void:
	_feed_lines.append("[color=%s][b]%s[/b][/color]  %s" % [_speaker_color(speaker), speaker, line])
	while _feed_lines.size() > 7:
		_feed_lines.pop_front()
	event_feed.text = "\n\n".join(_feed_lines)


func _speaker_color(speaker: String) -> String:
	match speaker:
		"HERALD":
			return "#ffbf3f"
		"PICKET":
			return "#63e4d1"
		"LOOT":
			return "#dc78ff"
		_:
			return "#ffffff"


func _build_graybox() -> void:
	_add_static_box("AnnexFloor", Vector3(0, -0.5, 0), Vector3(28, 1, 28), Color("223346"))
	_add_static_box("NorthWall", Vector3(0, 2.0, -14), Vector3(28, 5, 1), Color("172536"))
	_add_static_box("SouthWall", Vector3(0, 2.0, 14), Vector3(28, 5, 1), Color("172536"))
	_add_static_box("EastWall", Vector3(14, 2.0, 0), Vector3(1, 5, 28), Color("172536"))
	_add_static_box("WestWall", Vector3(-14, 2.0, 0), Vector3(1, 5, 28), Color("172536"))
	_add_static_box("LeftPlatform", Vector3(-7, 0.5, -5), Vector3(5, 1, 6), Color("2f5360"))
	_add_static_box("RightPlatform", Vector3(7, 1.0, 2), Vector3(5, 2, 6), Color("4b405f"))
	_add_static_box("ClerkDais", Vector3(0, 0.25, -7), Vector3(5, 0.5, 3), Color("69434e"))
	_add_static_box("PipeCoverA", Vector3(-4, 0.75, 3), Vector3(1.2, 1.5, 8), Color("355e64"))
	_add_static_box("PipeCoverB", Vector3(4, 0.75, -2), Vector3(1.2, 1.5, 8), Color("355e64"))


func _add_static_box(node_name: String, box_position: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = box_position
	body.collision_layer = 4
	body.collision_mask = 3
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	mesh_instance.material_override = material
	body.add_child(mesh_instance)
	add_child(body)


func _spawn_reward_display(item: Dictionary, reward_position: Vector3) -> void:
	var display := Node3D.new()
	display.name = "Reward_%d" % _reward_roll_index
	display.position = reward_position + Vector3(0, 0.85, 0)
	var mesh_instance := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.36
	sphere.height = 0.72
	mesh_instance.mesh = sphere
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("dc78ff")
	material.emission_enabled = true
	material.emission = Color("6d2f87")
	material.emission_energy_multiplier = 2.2
	mesh_instance.material_override = material
	display.add_child(mesh_instance)
	var label := Label3D.new()
	label.position = Vector3(0, 0.85, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.outline_size = 8
	label.font_size = 28
	label.text = String(item["display_name"])
	display.add_child(label)
	add_child(display)
