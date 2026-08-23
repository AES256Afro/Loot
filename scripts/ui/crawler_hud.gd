class_name CrawlerHUD
extends CanvasLayer

signal action_selected(action: String)
signal target_selected(target_index: int)
signal resolve_requested
signal reset_plan_requested
signal interact_requested
signal reward_closed
signal new_expedition_requested
signal return_to_dungeon_requested

const REFERENCE_SIZE := Vector2(1600, 900)

var _objective_label: Label
var _subhead_label: Label
var _party_box: VBoxContainer
var _map_label: Label
var _room_hint: RichTextLabel
var _enemy_box: VBoxContainer
var _enemy_panel: PanelContainer
var _command_panel: PanelContainer
var _command_title: Label
var _action_buttons: Array[Button] = []
var _resolve_button: Button
var _reset_button: Button
var _event_feed: RichTextLabel
var _help_label: Label
var _reward_modal: PanelContainer
var _reward_title: Label
var _reward_details: RichTextLabel
var _hearthfold_modal: PanelContainer
var _hearthfold_details: RichTextLabel
var _feed_lines: Array[String] = []
var _selected_target := 0


func _ready() -> void:
	_build_interface()


func set_exploration(
	room_title: String,
	progress_text: String,
	map_text: String,
	hint_text: String,
	party: Array,
	inventory_count: int,
	seed: int
) -> void:
	_objective_label.text = "GUTTERBLOOM EXPEDITION  |  %s" % room_title.to_upper()
	_subhead_label.text = "%s  |  Seed %d  |  Archive %d" % [progress_text, seed, inventory_count]
	_map_label.text = map_text
	_room_hint.text = hint_text
	_update_party(party, -1, [])
	_enemy_panel.hide()
	_command_panel.hide()
	_help_label.text = "W / Up move forward   S / Down move back   A,D / Left,Right turn   E interact   F5 save   F9 load"


func set_combat(
	party: Array,
	enemies: Array,
	intents: Array,
	round_index: int,
	active_member: int,
	commands: Array,
	selected_target: int,
	environment_primed: bool
) -> void:
	_selected_target = selected_target
	_objective_label.text = "COMBAT STOPPED  |  ROUND %d  |  PLAN WITHOUT A TIMER" % round_index
	_subhead_label.text = "Choose one command for every living party member, inspect intentions, then Resolve."
	_update_party(party, active_member, commands)
	_update_enemies(enemies, intents, selected_target)
	_enemy_panel.show()
	_command_panel.show()
	_command_title.text = _command_prompt(party, active_member, environment_primed)
	var can_plan := active_member >= 0
	for button in _action_buttons:
		button.disabled = not can_plan
	_resolve_button.disabled = active_member >= 0
	_reset_button.disabled = false
	_help_label.text = "1 Strike   2 Power   3 Guard   4 Expose   Left/Right target   Enter Resolve   Backspace reset plan"
	if can_plan and not _action_buttons.is_empty():
		_action_buttons[0].grab_focus()
	elif not _resolve_button.disabled:
		_resolve_button.grab_focus()


func set_resolving() -> void:
	_objective_label.text = "RESOLVING THE FILED PLAN"
	_subhead_label.text = "Time advances only for this exchange."
	for button in _action_buttons:
		button.disabled = true
	_resolve_button.disabled = true
	_reset_button.disabled = true


func push_line(speaker: String, line: String) -> void:
	_feed_lines.append("[color=%s][b]%s[/b][/color]  %s" % [_speaker_color(speaker), speaker, line])
	while _feed_lines.size() > 9:
		_feed_lines.pop_front()
	_event_feed.text = "\n\n".join(_feed_lines)
	_event_feed.scroll_to_line(maxi(0, _event_feed.get_line_count() - 1))


func clear_feed() -> void:
	_feed_lines.clear()
	_event_feed.text = ""


func show_reward(item: Dictionary, archive_count: int) -> void:
	_objective_label.text = "REWARD SECURED  |  COMBAT TIME REMAINS STOPPED"
	_subhead_label.text = "The baseline roll has already entered the persistent Archive. There is no claim timer."
	_enemy_panel.hide()
	_command_panel.hide()
	_reward_title.text = "%s  [%s]" % [String(item.get("display_name", "Unknown Reward")), String(item.get("rarity", "unknown")).to_upper()]
	_reward_details.text = "[color=#dc78ff][b]%s[/b][/color]\n\n%s\n\n[color=#f3c968][b]%s[/b][/color]\n%s\n\nSlot: %s\nArchive copies earned this profile: %d" % [
		String(item.get("description", "")),
		"BASELINE REWARD SECURED",
		String(item.get("power_id", "power.unknown")),
		String(item.get("power_text", "")),
		String(item.get("slot", "unknown")).capitalize(),
		archive_count,
	]
	_reward_modal.show()
	var continue_button := _reward_modal.get_node("Content/Continue") as Button
	continue_button.grab_focus()


func hide_reward() -> void:
	_reward_modal.hide()


func show_hearthfold(summary: String) -> void:
	_hearthfold_details.text = summary
	_hearthfold_modal.show()
	var new_button := _hearthfold_modal.get_node("Content/Buttons/NewExpedition") as Button
	new_button.grab_focus()


func hide_hearthfold() -> void:
	_hearthfold_modal.hide()


func modal_open() -> bool:
	return _reward_modal.visible or _hearthfold_modal.visible


func _build_interface() -> void:
	var root := Control.new()
	root.name = "Interface"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var top_panel := _panel(root, Rect2(18, 16, 1564, 70), Color("101722e8"), Color("d49d3b"))
	var top_content := _absolute_content(top_panel)
	_objective_label = _label(top_content, Rect2(18, 7, 1528, 31), 23, Color("f3d486"))
	_subhead_label = _label(top_content, Rect2(18, 37, 1528, 24), 16, Color("aabac5"))

	var party_panel := _panel(root, Rect2(18, 100, 302, 655), Color("111a23e8"), Color("4d8b83"))
	var party_margin := _margin(party_panel, 14)
	_party_box = VBoxContainer.new()
	_party_box.add_theme_constant_override("separation", 9)
	party_margin.add_child(_party_box)

	var map_panel := _panel(root, Rect2(1280, 100, 302, 340), Color("111a23e8"), Color("4d8b83"))
	var map_content := _absolute_content(map_panel)
	_map_label = _label(map_content, Rect2(14, 10, 274, 192), 16, Color("87d7cb"))
	_map_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_map_label.text = "DUNGEON MAP"
	_room_hint = RichTextLabel.new()
	_room_hint.position = Vector2(14, 206)
	_room_hint.size = Vector2(274, 120)
	_room_hint.bbcode_enabled = true
	_room_hint.fit_content = false
	_room_hint.scroll_active = false
	_room_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_room_hint.add_theme_font_size_override("normal_font_size", 14)
	_room_hint.add_theme_color_override("default_color", Color("cbd5d5"))
	map_content.add_child(_room_hint)

	_enemy_panel = _panel(root, Rect2(1280, 454, 302, 301), Color("20131be8"), Color("b64c5c"))
	var enemy_margin := _margin(_enemy_panel, 12)
	_enemy_box = VBoxContainer.new()
	_enemy_box.add_theme_constant_override("separation", 7)
	enemy_margin.add_child(_enemy_box)

	var feed_panel := _panel(root, Rect2(336, 650, 928, 232), Color("0d121be8"), Color("3a5669"))
	var feed_content := _absolute_content(feed_panel)
	_event_feed = RichTextLabel.new()
	_event_feed.position = Vector2(14, 12)
	_event_feed.size = Vector2(900, 208)
	_event_feed.bbcode_enabled = true
	_event_feed.scroll_active = true
	_event_feed.scroll_following = true
	_event_feed.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_event_feed.add_theme_font_size_override("normal_font_size", 17)
	_event_feed.add_theme_font_size_override("bold_font_size", 17)
	_event_feed.add_theme_color_override("default_color", Color("d7dde0"))
	feed_content.add_child(_event_feed)

	_command_panel = _panel(root, Rect2(336, 470, 928, 166), Color("14101ce8"), Color("9c63b5"))
	var command_content := _absolute_content(_command_panel)
	_command_title = _label(command_content, Rect2(14, 8, 900, 29), 17, Color("e0c7eb"))
	var action_row := HBoxContainer.new()
	action_row.position = Vector2(14, 44)
	action_row.size = Vector2(900, 52)
	action_row.add_theme_constant_override("separation", 9)
	command_content.add_child(action_row)
	var actions := [
		["1  STRIKE", CombatResolver.ACTION_STRIKE],
		["2  POWER", CombatResolver.ACTION_POWER],
		["3  GUARD", CombatResolver.ACTION_GUARD],
		["4  EXPOSE", CombatResolver.ACTION_UTILITY],
	]
	for action_data in actions:
		var action_button := _button(String(action_data[0]), Vector2(171, 50))
		action_button.pressed.connect(_emit_action.bind(String(action_data[1])))
		action_row.add_child(action_button)
		_action_buttons.append(action_button)
	_resolve_button = _button("RESOLVE", Vector2(171, 50))
	_resolve_button.pressed.connect(func() -> void: resolve_requested.emit())
	action_row.add_child(_resolve_button)
	_reset_button = _button("RESET PLAN", Vector2(171, 50))
	_reset_button.pressed.connect(func() -> void: reset_plan_requested.emit())
	action_row.add_child(_reset_button)

	_help_label = _label(root, Rect2(24, 864, 1552, 26), 15, Color("8ea0aa"))
	_help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_reward_modal = _build_reward_modal(root)
	_hearthfold_modal = _build_hearthfold_modal(root)
	_enemy_panel.hide()
	_command_panel.hide()
	_reward_modal.hide()
	_hearthfold_modal.hide()


func _build_reward_modal(parent: Control) -> PanelContainer:
	var modal := _panel(parent, Rect2(405, 180, 790, 520), Color("171021fa"), Color("d66dfa"), 5)
	modal.name = "RewardModal"
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	var content := VBoxContainer.new()
	content.name = "Content"
	content.position = Vector2(34, 28)
	content.size = Vector2(722, 464)
	content.add_theme_constant_override("separation", 18)
	modal.add_child(content)
	var heading := Label.new()
	heading.text = "REWARD FILED WITHOUT INCIDENT"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color("a9b7bf"))
	content.add_child(heading)
	_reward_title = Label.new()
	_reward_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reward_title.add_theme_font_size_override("font_size", 30)
	_reward_title.add_theme_color_override("font_color", Color("edb8ff"))
	content.add_child(_reward_title)
	_reward_details = RichTextLabel.new()
	_reward_details.custom_minimum_size = Vector2(710, 300)
	_reward_details.bbcode_enabled = true
	_reward_details.fit_content = false
	_reward_details.add_theme_font_size_override("normal_font_size", 18)
	_reward_details.add_theme_font_size_override("bold_font_size", 18)
	_reward_details.add_theme_color_override("default_color", Color("d7d4dc"))
	content.add_child(_reward_details)
	var continue_button := _button("CONTINUE EXPEDITION", Vector2(360, 52))
	continue_button.name = "Continue"
	continue_button.pressed.connect(func() -> void: reward_closed.emit())
	continue_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(continue_button)
	return modal


func _build_hearthfold_modal(parent: Control) -> PanelContainer:
	var modal := _panel(parent, Rect2(405, 180, 790, 520), Color("0c2024fa"), Color("66e5d0"), 5)
	modal.name = "HearthfoldModal"
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	var content := VBoxContainer.new()
	content.name = "Content"
	content.position = Vector2(34, 28)
	content.size = Vector2(722, 464)
	content.add_theme_constant_override("separation", 20)
	modal.add_child(content)
	var heading := Label.new()
	heading.text = "THE HEARTHFOLD"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 34)
	heading.add_theme_color_override("font_color", Color("8df5e5"))
	content.add_child(heading)
	_hearthfold_details = RichTextLabel.new()
	_hearthfold_details.custom_minimum_size = Vector2(710, 310)
	_hearthfold_details.bbcode_enabled = true
	_hearthfold_details.fit_content = false
	_hearthfold_details.add_theme_font_size_override("normal_font_size", 19)
	_hearthfold_details.add_theme_color_override("default_color", Color("d6efeb"))
	content.add_child(_hearthfold_details)
	var buttons := HBoxContainer.new()
	buttons.name = "Buttons"
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 18)
	content.add_child(buttons)
	var return_button := _button("RETURN TO DUNGEON", Vector2(270, 54))
	return_button.name = "Return"
	return_button.pressed.connect(func() -> void: return_to_dungeon_requested.emit())
	buttons.add_child(return_button)
	var new_button := _button("NEW EXPEDITION", Vector2(270, 54))
	new_button.name = "NewExpedition"
	new_button.pressed.connect(func() -> void: new_expedition_requested.emit())
	buttons.add_child(new_button)
	return modal


func _update_party(party: Array, active_member: int, commands: Array) -> void:
	_clear_children(_party_box)
	var heading := Label.new()
	heading.text = "EXPEDITION PARTY"
	heading.add_theme_font_size_override("font_size", 19)
	heading.add_theme_color_override("font_color", Color("84e4d4"))
	_party_box.add_child(heading)
	for index in range(party.size()):
		var member: Dictionary = party[index]
		var panel := PanelContainer.new()
		var style := StyleBoxFlat.new()
		style.bg_color = Color("24303b") if index != active_member else Color("493557")
		style.border_color = Color(member.get("color", "#ffffff"))
		style.set_border_width_all(2 if index == active_member else 1)
		style.set_corner_radius_all(4)
		panel.add_theme_stylebox_override("panel", style)
		panel.custom_minimum_size = Vector2(270, 92)
		var label := Label.new()
		label.position = Vector2(10, 8)
		label.size = Vector2(250, 76)
		var hp := int(member.get("hp", 0))
		var max_hp := int(member.get("max_hp", 1))
		var command_text := ""
		if index < commands.size() and typeof(commands[index]) == TYPE_DICTIONARY and not (commands[index] as Dictionary).is_empty():
			command_text = "\nFiled: %s" % String((commands[index] as Dictionary).get("action", "")).capitalize()
		label.text = "%s  |  %s\nHP %d / %d%s" % [member["name"], member["role"], hp, max_hp, command_text]
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", Color("e3e7e8") if hp > 0 else Color("7b6670"))
		panel.add_child(label)
		_party_box.add_child(panel)


func _update_enemies(enemies: Array, intents: Array, selected_target: int) -> void:
	_clear_children(_enemy_box)
	var heading := Label.new()
	heading.text = "ENEMY INTENTIONS"
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color("f17882"))
	_enemy_box.add_child(heading)
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index]
		var button := Button.new()
		button.custom_minimum_size = Vector2(270, 70)
		button.text = "%s%s\nHP %d / %d\n%s" % [
			"> " if index == selected_target else "",
			enemy["name"],
			int(enemy["hp"]),
			int(enemy["max_hp"]),
			_intent_text(intents, index),
		]
		button.disabled = int(enemy["hp"]) <= 0
		button.pressed.connect(_emit_target.bind(index))
		button.add_theme_font_size_override("font_size", 15)
		_enemy_box.add_child(button)


func _command_prompt(party: Array, active_member: int, environment_primed: bool) -> String:
	if active_member < 0 or active_member >= party.size():
		return "Plan filed. Review enemy intentions, then RESOLVE."
	var member: Dictionary = party[active_member]
	return "%s the %s: choose an action. Power: %s%s" % [
		member["name"],
		member["role"],
		member["power"],
		"  |  PRESSURE LINE PRIMED" if environment_primed else "",
	]


func _intent_text(intents: Array, enemy_index: int) -> String:
	for intent in intents:
		if int(intent.get("enemy_index", -1)) == enemy_index:
			return String(intent.get("text", "Intent unknown"))
	return "Defeated"


func _emit_action(action: String) -> void:
	action_selected.emit(action)


func _emit_target(index: int) -> void:
	_selected_target = index
	target_selected.emit(index)


func _panel(parent: Control, rect: Rect2, background: Color, border: Color, width: int = 2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = rect.position
	panel.size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(5)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel


func _label(parent: Node, rect: Rect2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _absolute_content(parent: PanelContainer) -> Control:
	var content := Control.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(content)
	return content


func _button(text_value: String, minimum: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = minimum
	button.add_theme_font_size_override("font_size", 15)
	return button


func _margin(parent: Control, margin: int) -> MarginContainer:
	var container := MarginContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		container.add_theme_constant_override(side, margin)
	parent.add_child(container)
	return container


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		child.queue_free()


func _speaker_color(speaker: String) -> String:
	match speaker:
		"HERALD":
			return "#f4bd4f"
		"PICKET":
			return "#6debd8"
		"LOOT":
			return "#dc78ff"
		"SYSTEM":
			return "#8aa5b5"
		_:
			return "#ffffff"
