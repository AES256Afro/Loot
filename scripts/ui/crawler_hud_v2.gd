class_name CrawlerHUDV2
extends CanvasLayer

signal action_selected(action: String)
signal target_selected(target_index: int)
signal resolve_requested
signal reset_plan_requested
signal interact_requested
signal reward_closed
signal new_expedition_requested
signal return_to_dungeon_requested
signal return_to_kingdom_requested
signal bent_pipe_requested
signal social_choice_selected(choice_id: String)
signal archive_requested
signal archive_closed
signal archive_equip_requested(item_id: String, destination_kind: String, destination_index: int)
signal archive_favorite_requested(item_id: String)
signal save_loadout_requested(loadout_name: String)
signal apply_loadout_requested(loadout_name: String)

const REFERENCE_SIZE := Vector2(1600, 900)
const RARITY_COLORS := {
	"common": "#bac5c5",
	"uncommon": "#72d596",
	"rare": "#65bfea",
	"epic": "#ce76ea",
	"legendary": "#f3b94f",
	"mythic": "#ff6a82",
}
const RARITY_ORDER := {"mythic": 6, "legendary": 5, "epic": 4, "rare": 3, "uncommon": 2, "common": 1}

var _assets := GeneratedAssetLibrary.new()
var _equipment := EquipmentService.new()

var _objective_label: Label
var _subhead_label: Label
var _party_box: HBoxContainer
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
var _loadout_badge: Label
var _reward_modal: PanelContainer
var _reward_title: Label
var _reward_details: RichTextLabel
var _hearthfold_modal: PanelContainer
var _hearthfold_details: RichTextLabel
var _bent_pipe_button: Button
var _return_kingdom_button: Button
var _social_modal: PanelContainer
var _social_title: Label
var _social_subtitle: Label
var _social_portrait: TextureRect
var _social_memory: RichTextLabel
var _social_opening: RichTextLabel
var _social_choices: VBoxContainer
var _social_footer: Label
var _archive_modal: PanelContainer
var _archive_list: ItemList
var _archive_filter: OptionButton
var _archive_destination: OptionButton
var _archive_icon: TextureRect
var _archive_title: Label
var _archive_details: RichTextLabel
var _archive_comparison: RichTextLabel
var _archive_favorite_button: Button
var _archive_equip_button: Button
var _archive_counter: Label
var _feed_lines: Array[String] = []
var _selected_target := 0
var _equipment_state: Dictionary = {}
var _definitions: Dictionary = {}
var _archive_inventory: Array = []
var _archive_selected_id := ""
var _party_cards: Array[PanelContainer] = []
var _party_portraits: Array[TextureRect] = []


func _ready() -> void:
	_build_interface()


func set_equipment_context(state: Dictionary, definitions: Dictionary) -> void:
	_equipment_state = state.duplicate(true)
	_definitions = definitions.duplicate(true)
	if _loadout_badge != null:
		_loadout_badge.text = "BUILD %s" % String(state.get("active_loadout", "CUSTOM"))
	if _archive_modal != null and _archive_modal.visible:
		refresh_archive(definitions, _archive_inventory, state)


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
	_room_hint.show()
	_update_party(party, -1, [])
	_enemy_panel.hide()
	_command_panel.hide()
	_help_label.text = "W / Up move   S / Down back   A,D / Left,Right turn   E interact   I Archive   F5 save   F9 load"


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
	_objective_label.text = "COMBAT STOPPED  |  ROUND %d  |  NO TIMER" % round_index
	_subhead_label.text = "File one command for each living party member. Time advances only when RESOLVE is chosen."
	_update_party(party, active_member, commands)
	_room_hint.hide()
	_update_enemies(enemies, intents, selected_target)
	_enemy_panel.show()
	_command_panel.show()
	_command_title.text = _command_prompt(party, active_member, environment_primed)
	var can_plan := active_member >= 0
	for button in _action_buttons:
		button.disabled = not can_plan
	_resolve_button.disabled = active_member >= 0
	_reset_button.disabled = false
	_help_label.text = "1 Strike   2 Power   3 Guard   4 Expose   5 Taunt   Left/Right target   Enter Resolve   Backspace reset"
	if can_plan and not _action_buttons.is_empty():
		_action_buttons[0].grab_focus()
	elif not _resolve_button.disabled:
		_resolve_button.grab_focus()


func set_resolving() -> void:
	_objective_label.text = "RESOLVING THE FILED PLAN"
	_subhead_label.text = "The dungeon has been authorized to move for exactly one exchange."
	for button in _action_buttons:
		button.disabled = true
	_resolve_button.disabled = true
	_reset_button.disabled = true


func push_line(speaker: String, line: String) -> void:
	_feed_lines.append("[color=%s][b]%s[/b][/color]  %s" % [_speaker_color(speaker), speaker, line])
	while _feed_lines.size() > 5:
		_feed_lines.pop_front()
	_event_feed.text = "\n\n".join(_feed_lines)
	_event_feed.scroll_to_line(maxi(0, _event_feed.get_line_count() - 1))


func clear_feed() -> void:
	_feed_lines.clear()
	_event_feed.text = ""


func show_reward(item: Dictionary, archive_count: int) -> void:
	_objective_label.text = "REWARD SECURED  |  COMBAT TIME REMAINS STOPPED"
	_subhead_label.text = "The baseline roll is already in the uncapped Archive. There is no claim timer and no item loss."
	_enemy_panel.hide()
	_command_panel.hide()
	_room_hint.hide()
	_reward_title.text = "%s  [%s]" % [String(item.get("display_name", "Unknown Reward")), String(item.get("rarity", "unknown")).to_upper()]
	_reward_title.add_theme_color_override("font_color", Color(RARITY_COLORS.get(String(item.get("rarity", "common")), "#ffffff")))
	_reward_details.text = "[color=#dc78ff][b]%s[/b][/color]\n\n[color=#f3c968][b]%s[/b][/color]\n%s\n\nSlot: %s\nArchive entries in this profile: %d" % [
		String(item.get("description", "")),
		String(item.get("power_id", "power.unknown")),
		String(item.get("power_text", "")),
		String(item.get("slot", "unknown")).capitalize(),
		archive_count,
	]
	_reward_modal.show()
	var continue_button := _reward_modal.get_node("Content/Buttons/Continue") as Button
	continue_button.grab_focus()


func hide_reward() -> void:
	_reward_modal.hide()


func show_hearthfold(summary: String, bar_available: bool = false, bar_status: String = "No recurring guest is currently available.", kingdom_available: bool = false) -> void:
	_hearthfold_details.text = summary
	_bent_pipe_button.disabled = not bar_available
	_bent_pipe_button.tooltip_text = bar_status
	_return_kingdom_button.disabled = not kingdom_available
	_return_kingdom_button.tooltip_text = "Return to the persistent strategic map at the exact dungeon entrance." if kingdom_available else "No kingdom entrance is anchored to this Hearthfold visit."
	_hearthfold_modal.show()
	if bar_available:
		_bent_pipe_button.grab_focus()
	else:
		var new_button := _hearthfold_modal.get_node("Content/Buttons/NewExpedition") as Button
		new_button.grab_focus()


func hide_hearthfold() -> void:
	_hearthfold_modal.hide()


func show_social(
	title: String,
	subtitle: String,
	memory_text: String,
	opening_lines: Array,
	options: Array,
	bar_mode: bool = false
) -> void:
	_social_title.text = title
	_social_subtitle.text = subtitle
	_social_memory.text = memory_text
	_social_portrait.texture = _assets.enemy_portrait("form_auditor")
	var rendered_opening: PackedStringArray = []
	for raw_line in opening_lines:
		if typeof(raw_line) != TYPE_DICTIONARY:
			continue
		var line: Dictionary = raw_line
		rendered_opening.append("[color=#f2c86d][b]%s[/b][/color]  %s" % [line.get("speaker", "Scrip"), line.get("line", "")])
	_social_opening.text = "\n\n".join(rendered_opening)
	_clear_children(_social_choices)
	var first_button: Button
	for raw_option in options:
		if typeof(raw_option) != TYPE_DICTIONARY:
			continue
		var option: Dictionary = raw_option
		var button := _button(RivalService.new().format_option(option), Vector2(748, 72))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.disabled = not bool(option.get("available", true))
		var prediction := String(option.get("prediction", "NO CHECK"))
		button.add_theme_color_override("font_color", Color("86e6a9") if prediction in ["PASS", "AVAILABLE"] else Color("f09a91") if prediction in ["FAIL", "LOCKED"] else Color("9ddfd8"))
		button.pressed.connect(func() -> void: social_choice_selected.emit(String(option.get("id", ""))))
		_social_choices.add_child(button)
		if first_button == null and not button.disabled:
			first_button = button
	_social_footer.text = "SEMI-SAFE NEUTRAL GROUND  |  WEAPONS CHECKED  |  INSULTS UNRESTRICTED  |  NO RESPONSE TIMER" if bar_mode else "COMBAT REMAINS STOPPED  |  CHECKS ARE DETERMINISTIC  |  NO RESPONSE TIMER  |  BASELINE REWARD PRESERVED"
	_social_modal.show()
	if first_button != null:
		first_button.grab_focus()


func hide_social() -> void:
	_social_modal.hide()


func social_is_open() -> bool:
	return _social_modal != null and _social_modal.visible


func show_archive(definitions: Dictionary, inventory: Array, state: Dictionary) -> void:
	refresh_archive(definitions, inventory, state)
	_archive_modal.show()
	_archive_list.grab_focus()


func refresh_archive(definitions: Dictionary, inventory: Array, state: Dictionary) -> void:
	_definitions = definitions.duplicate(true)
	_archive_inventory = inventory.duplicate()
	_equipment_state = state.duplicate(true)
	_loadout_badge.text = "BUILD %s" % String(state.get("active_loadout", "CUSTOM"))
	_archive_rebuild_list()


func hide_archive() -> void:
	_archive_modal.hide()


func archive_is_open() -> bool:
	return _archive_modal != null and _archive_modal.visible


func modal_open() -> bool:
	return _reward_modal.visible or _hearthfold_modal.visible or _archive_modal.visible or _social_modal.visible


func _build_interface() -> void:
	var root := Control.new()
	root.name = "Interface"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var top_panel := _panel(root, Rect2(18, 14, 1564, 68), Color("0b1119ed"), Color("d6a348"), 3)
	var top_content := _absolute_content(top_panel)
	_objective_label = _label(top_content, Rect2(18, 6, 1000, 31), 23, Color("f3d486"))
	_subhead_label = _label(top_content, Rect2(18, 36, 1000, 24), 15, Color("b7c5ca"))
	var kingdom_button := _button("K  KINGDOM", Vector2(150, 46))
	kingdom_button.position = Vector2(1024, 8)
	kingdom_button.tooltip_text = "Safely extract to the exact entrance hex without losing owned items or accepted quests."
	kingdom_button.pressed.connect(func() -> void: return_to_kingdom_requested.emit())
	top_content.add_child(kingdom_button)
	_loadout_badge = _label(top_content, Rect2(1180, 12, 106, 38), 18, Color("77e6d5"))
	_loadout_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var archive_button := _button("I  ARCHIVE", Vector2(218, 46))
	archive_button.position = Vector2(1298, 8)
	archive_button.pressed.connect(func() -> void: archive_requested.emit())
	top_content.add_child(archive_button)

	var feed_panel := _panel(root, Rect2(18, 98, 500, 174), Color("081019b8"), Color("496878"), 2)
	var feed_content := _absolute_content(feed_panel)
	_event_feed = RichTextLabel.new()
	_event_feed.position = Vector2(14, 10)
	_event_feed.size = Vector2(472, 152)
	_event_feed.bbcode_enabled = true
	_event_feed.scroll_active = true
	_event_feed.scroll_following = true
	_event_feed.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_event_feed.add_theme_font_size_override("normal_font_size", 16)
	_event_feed.add_theme_font_size_override("bold_font_size", 16)
	_event_feed.add_theme_color_override("default_color", Color("e0e5e5"))
	feed_content.add_child(_event_feed)

	var map_panel := _panel(root, Rect2(1278, 98, 304, 270), Color("09141cca"), Color("4b908b"), 2)
	var map_content := _absolute_content(map_panel)
	_map_label = _label(map_content, Rect2(14, 8, 276, 142), 15, Color("8be0d2"))
	_map_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_room_hint = RichTextLabel.new()
	_room_hint.position = Vector2(14, 154)
	_room_hint.size = Vector2(276, 104)
	_room_hint.bbcode_enabled = true
	_room_hint.scroll_active = false
	_room_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_room_hint.add_theme_font_size_override("normal_font_size", 13)
	_room_hint.add_theme_color_override("default_color", Color("d0dada"))
	map_content.add_child(_room_hint)

	_enemy_panel = _panel(root, Rect2(1278, 382, 304, 252), Color("1a0d15dd"), Color("bd5364"), 2)
	var enemy_margin := _margin(_enemy_panel, 11)
	_enemy_box = VBoxContainer.new()
	_enemy_box.add_theme_constant_override("separation", 5)
	enemy_margin.add_child(_enemy_box)

	var party_panel := _panel(root, Rect2(18, 642, 810, 206), Color("0b151ddd"), Color("4f938b"), 3)
	var party_margin := _margin(party_panel, 10)
	_party_box = HBoxContainer.new()
	_party_box.add_theme_constant_override("separation", 8)
	party_margin.add_child(_party_box)

	_command_panel = _panel(root, Rect2(842, 642, 422, 206), Color("120d19ed"), Color("a364ba"), 3)
	var command_content := _absolute_content(_command_panel)
	_command_title = _label(command_content, Rect2(14, 8, 394, 42), 15, Color("e2caec"))
	_command_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var action_grid := GridContainer.new()
	action_grid.columns = 2
	action_grid.position = Vector2(14, 54)
	action_grid.size = Vector2(394, 136)
	action_grid.add_theme_constant_override("h_separation", 8)
	action_grid.add_theme_constant_override("v_separation", 7)
	command_content.add_child(action_grid)
	var actions := [
		["1  STRIKE", CombatResolver.ACTION_STRIKE, 0],
		["2  POWER", CombatResolver.ACTION_POWER, 6],
		["3  GUARD", CombatResolver.ACTION_GUARD, 2],
		["4  EXPOSE", CombatResolver.ACTION_UTILITY, 14],
		["5  TAUNT", CombatResolver.ACTION_TAUNT, 11],
	]
	for action_data in actions:
		var action_button := _button(String(action_data[0]), Vector2(191, 30))
		action_button.icon = _assets.equipment_icon(int(action_data[2]))
		action_button.expand_icon = true
		action_button.pressed.connect(_emit_action.bind(String(action_data[1])))
		action_grid.add_child(action_button)
		_action_buttons.append(action_button)
	_resolve_button = _button("RESOLVE", Vector2(191, 30))
	_resolve_button.pressed.connect(func() -> void: resolve_requested.emit())
	action_grid.add_child(_resolve_button)
	_reset_button = _button("RESET PLAN", Vector2(191, 30))
	_reset_button.pressed.connect(func() -> void: reset_plan_requested.emit())
	action_grid.add_child(_reset_button)

	_help_label = _label(root, Rect2(24, 864, 1552, 24), 14, Color("98a8ae"))
	_help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_reward_modal = _build_reward_modal(root)
	_hearthfold_modal = _build_hearthfold_modal(root)
	_archive_modal = _build_archive_modal(root)
	_social_modal = _build_social_modal(root)
	_enemy_panel.hide()
	_command_panel.hide()
	_reward_modal.hide()
	_hearthfold_modal.hide()
	_archive_modal.hide()
	_social_modal.hide()


func _build_reward_modal(parent: Control) -> PanelContainer:
	var modal := _panel(parent, Rect2(405, 170, 790, 540), Color("171021fc"), Color("d66dfa"), 5)
	modal.name = "RewardModal"
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	var content := VBoxContainer.new()
	content.name = "Content"
	content.position = Vector2(34, 28)
	content.size = Vector2(722, 484)
	content.add_theme_constant_override("separation", 15)
	modal.add_child(content)
	var heading := _simple_label("REWARD FILED WITHOUT INCIDENT", 18, Color("a9b7bf"))
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(heading)
	_reward_title = _simple_label("", 29, Color("edb8ff"))
	_reward_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_reward_title)
	_reward_details = RichTextLabel.new()
	_reward_details.custom_minimum_size = Vector2(710, 310)
	_reward_details.bbcode_enabled = true
	_reward_details.add_theme_font_size_override("normal_font_size", 18)
	_reward_details.add_theme_font_size_override("bold_font_size", 18)
	_reward_details.add_theme_color_override("default_color", Color("ddd9e0"))
	content.add_child(_reward_details)
	var buttons := HBoxContainer.new()
	buttons.name = "Buttons"
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	content.add_child(buttons)
	var archive_button := _button("OPEN ARCHIVE", Vector2(250, 50))
	archive_button.pressed.connect(func() -> void: archive_requested.emit())
	buttons.add_child(archive_button)
	var continue_button := _button("CONTINUE", Vector2(250, 50))
	continue_button.name = "Continue"
	continue_button.pressed.connect(func() -> void: reward_closed.emit())
	buttons.add_child(continue_button)
	return modal


func _build_hearthfold_modal(parent: Control) -> PanelContainer:
	var modal := _panel(parent, Rect2(405, 170, 790, 540), Color("0c2024fc"), Color("66e5d0"), 5)
	modal.name = "HearthfoldModal"
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	var content := VBoxContainer.new()
	content.name = "Content"
	content.position = Vector2(34, 28)
	content.size = Vector2(722, 484)
	content.add_theme_constant_override("separation", 18)
	modal.add_child(content)
	var heading := _simple_label("THE HEARTHFOLD", 34, Color("8df5e5"))
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(heading)
	_hearthfold_details = RichTextLabel.new()
	_hearthfold_details.custom_minimum_size = Vector2(710, 300)
	_hearthfold_details.bbcode_enabled = true
	_hearthfold_details.add_theme_font_size_override("normal_font_size", 19)
	_hearthfold_details.add_theme_color_override("default_color", Color("d6efeb"))
	content.add_child(_hearthfold_details)
	var buttons := HBoxContainer.new()
	buttons.name = "Buttons"
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 18)
	content.add_child(buttons)
	var return_button := _button("RETURN TO DUNGEON", Vector2(150, 54))
	return_button.name = "Return"
	return_button.pressed.connect(func() -> void: return_to_dungeon_requested.emit())
	buttons.add_child(return_button)
	_bent_pipe_button = _button("THE BENT PIPE", Vector2(165, 54))
	_bent_pipe_button.name = "BentPipe"
	_bent_pipe_button.pressed.connect(func() -> void: bent_pipe_requested.emit())
	buttons.add_child(_bent_pipe_button)
	_return_kingdom_button = _button("KINGDOM MAP", Vector2(165, 54))
	_return_kingdom_button.name = "KingdomMap"
	_return_kingdom_button.pressed.connect(func() -> void: return_to_kingdom_requested.emit())
	buttons.add_child(_return_kingdom_button)
	var new_button := _button("NEW EXPEDITION", Vector2(150, 54))
	new_button.name = "NewExpedition"
	new_button.pressed.connect(func() -> void: new_expedition_requested.emit())
	buttons.add_child(new_button)
	return modal


func _build_social_modal(parent: Control) -> PanelContainer:
	var modal := _panel(parent, Rect2(116, 76, 1368, 748), Color("081118f7"), Color("d3a94d"), 5)
	modal.name = "SocialModal"
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	var content := _absolute_content(modal)
	_social_title = _label(content, Rect2(28, 20, 1310, 42), 31, Color("f3cf76"))
	_social_subtitle = _label(content, Rect2(30, 62, 1310, 30), 17, Color("80e4d6"))
	_social_portrait = TextureRect.new()
	_social_portrait.position = Vector2(30, 112)
	_social_portrait.size = Vector2(278, 278)
	_social_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_social_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_social_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	content.add_child(_social_portrait)
	var record_heading := _label(content, Rect2(30, 406, 330, 28), 18, Color("f0c96f"))
	record_heading.text = "INSPECTABLE MEMORY AND PRESSURES"
	_social_memory = RichTextLabel.new()
	_social_memory.position = Vector2(30, 440)
	_social_memory.size = Vector2(350, 236)
	_social_memory.bbcode_enabled = true
	_social_memory.scroll_active = false
	_social_memory.add_theme_font_size_override("normal_font_size", 16)
	_social_memory.add_theme_font_size_override("bold_font_size", 16)
	_social_memory.add_theme_color_override("default_color", Color("d6dfe0"))
	content.add_child(_social_memory)
	var dialogue_panel := _panel(content, Rect2(400, 108, 932, 146), Color("16111ce8"), Color("76548b"), 2)
	var dialogue_content := _absolute_content(dialogue_panel)
	_social_opening = RichTextLabel.new()
	_social_opening.position = Vector2(18, 12)
	_social_opening.size = Vector2(896, 120)
	_social_opening.bbcode_enabled = true
	_social_opening.scroll_active = false
	_social_opening.add_theme_font_size_override("normal_font_size", 17)
	_social_opening.add_theme_font_size_override("bold_font_size", 17)
	_social_opening.add_theme_color_override("default_color", Color("e6e1e8"))
	dialogue_content.add_child(_social_opening)
	_social_choices = VBoxContainer.new()
	_social_choices.position = Vector2(400, 270)
	_social_choices.size = Vector2(932, 402)
	_social_choices.add_theme_constant_override("separation", 7)
	content.add_child(_social_choices)
	_social_footer = _label(content, Rect2(28, 700, 1312, 28), 14, Color("a8b8bb"))
	_social_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return modal


func _build_archive_modal(parent: Control) -> PanelContainer:
	var modal := _panel(parent, Rect2(74, 48, 1452, 806), Color("081118fe"), Color("d7a94c"), 5)
	modal.name = "ArchiveModal"
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	var content := _absolute_content(modal)
	var heading := _label(content, Rect2(28, 18, 900, 40), 30, Color("f2cd72"))
	heading.text = "THE ARCHIVE  |  UNCAPPED, UNSALVAGED, UNHURRIED"
	_archive_counter = _label(content, Rect2(790, 22, 390, 34), 17, Color("82e7d8"))
	_archive_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var close_button := _button("CLOSE  [I / ESC]", Vector2(150, 42))
	close_button.position = Vector2(1268, 14)
	close_button.pressed.connect(func() -> void: archive_closed.emit())
	content.add_child(close_button)

	_archive_filter = OptionButton.new()
	_archive_filter.position = Vector2(28, 70)
	_archive_filter.size = Vector2(250, 44)
	for filter_name in ["ALL ITEMS", "FAVORITES", "DENA", "MOSS", "VELL", "ILEX", "SHARED RELICS", "ARCHIVE ONLY"]:
		_archive_filter.add_item(filter_name)
	_archive_filter.item_selected.connect(func(_index: int) -> void: _archive_rebuild_list())
	content.add_child(_archive_filter)

	_archive_destination = OptionButton.new()
	_archive_destination.position = Vector2(292, 70)
	_archive_destination.size = Vector2(250, 44)
	for destination_name in ["DENA", "MOSS", "VELL", "ILEX", "SHARED RELIC 1", "SHARED RELIC 2"]:
		_archive_destination.add_item(destination_name)
	_archive_destination.item_selected.connect(func(_index: int) -> void: _archive_update_details())
	content.add_child(_archive_destination)

	_archive_list = ItemList.new()
	_archive_list.position = Vector2(28, 126)
	_archive_list.size = Vector2(514, 610)
	_archive_list.fixed_icon_size = Vector2i(54, 54)
	_archive_list.icon_mode = ItemList.ICON_MODE_LEFT
	_archive_list.max_columns = 1
	_archive_list.add_theme_font_size_override("font_size", 17)
	_archive_list.item_selected.connect(func(_index: int) -> void: _archive_select_current())
	_archive_list.item_activated.connect(func(_index: int) -> void: _archive_emit_equip())
	content.add_child(_archive_list)

	var details_panel := _panel(content, Rect2(566, 70, 852, 666), Color("101b24ef"), Color("4c8f89"), 2)
	var details := _absolute_content(details_panel)
	_archive_icon = TextureRect.new()
	_archive_icon.position = Vector2(24, 24)
	_archive_icon.size = Vector2(144, 144)
	_archive_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_archive_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_archive_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	details.add_child(_archive_icon)
	_archive_title = _label(details, Rect2(190, 25, 630, 78), 29, Color("f2d58a"))
	_archive_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_archive_details = RichTextLabel.new()
	_archive_details.position = Vector2(190, 108)
	_archive_details.size = Vector2(630, 164)
	_archive_details.bbcode_enabled = true
	_archive_details.add_theme_font_size_override("normal_font_size", 17)
	_archive_details.add_theme_font_size_override("bold_font_size", 17)
	_archive_details.add_theme_color_override("default_color", Color("dbe1e2"))
	details.add_child(_archive_details)
	var compare_heading := _label(details, Rect2(24, 292, 796, 28), 18, Color("81e4d6"))
	compare_heading.text = "EQUIPPED COMPARISON"
	_archive_comparison = RichTextLabel.new()
	_archive_comparison.position = Vector2(24, 326)
	_archive_comparison.size = Vector2(796, 178)
	_archive_comparison.bbcode_enabled = true
	_archive_comparison.add_theme_font_size_override("normal_font_size", 16)
	_archive_comparison.add_theme_color_override("default_color", Color("c8d5d6"))
	details.add_child(_archive_comparison)
	_archive_favorite_button = _button("FAVORITE", Vector2(220, 48))
	_archive_favorite_button.position = Vector2(24, 522)
	_archive_favorite_button.pressed.connect(func() -> void:
		if not _archive_selected_id.is_empty():
			archive_favorite_requested.emit(_archive_selected_id)
	)
	details.add_child(_archive_favorite_button)
	_archive_equip_button = _button("EQUIP TO DESTINATION", Vector2(300, 48))
	_archive_equip_button.position = Vector2(258, 522)
	_archive_equip_button.pressed.connect(_archive_emit_equip)
	details.add_child(_archive_equip_button)

	var loadout_label := _label(details, Rect2(24, 586, 112, 36), 18, Color("f0c66c"))
	loadout_label.text = "LOADOUTS"
	var x := 144
	for action_data in [["APPLY A", "apply", "A"], ["SAVE A", "save", "A"], ["APPLY B", "apply", "B"], ["SAVE B", "save", "B"]]:
		var button := _button(String(action_data[0]), Vector2(154, 40))
		button.position = Vector2(x, 580)
		if String(action_data[1]) == "apply":
			button.pressed.connect(func() -> void: apply_loadout_requested.emit(String(action_data[2])))
		else:
			button.pressed.connect(func() -> void: save_loadout_requested.emit(String(action_data[2])))
		details.add_child(button)
		x += 164
	var footer := _label(content, Rect2(28, 752, 1390, 28), 15, Color("aebfc2"))
	footer.text = "Arrow keys select  |  Enter equips  |  Destination chooses party member or relic slot  |  Favoriting never changes drop odds"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return modal


func _update_party(party: Array, active_member: int, commands: Array) -> void:
	_clear_children(_party_box)
	_party_cards.clear()
	_party_portraits.clear()
	for index in range(party.size()):
		var member: Dictionary = party[index]
		var panel := PanelContainer.new()
		var style := StyleBoxFlat.new()
		style.bg_color = Color("301f3bdc") if index == active_member else Color("15232cdd")
		style.border_color = Color(member.get("color", "#ffffff"))
		style.set_border_width_all(3 if index == active_member else 1)
		style.set_corner_radius_all(5)
		panel.add_theme_stylebox_override("panel", style)
		panel.custom_minimum_size = Vector2(191, 182)
		var card := Control.new()
		panel.add_child(card)
		var portrait := TextureRect.new()
		portrait.position = Vector2(8, 8)
		portrait.size = Vector2(78, 92)
		portrait.texture = _assets.party_portrait(index)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		card.add_child(portrait)
		_party_cards.append(panel)
		_party_portraits.append(portrait)
		var hp := int(member.get("hp", 0))
		var max_hp := int(member.get("max_hp", 1))
		var command_text := "AWAITING"
		if index < commands.size() and typeof(commands[index]) == TYPE_DICTIONARY and not (commands[index] as Dictionary).is_empty():
			command_text = String((commands[index] as Dictionary).get("action", "")).to_upper()
		var text := _label(card, Rect2(92, 9, 91, 94), 14, Color("edf2f2") if hp > 0 else Color("846c78"))
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.text = "%s\n[color]" % member.get("name", "?")
		text.text = "%s\n%s\nHP %d/%d\n%s" % [member.get("name", "?"), member.get("role", "?"), hp, max_hp, command_text]
		var hp_bar := ProgressBar.new()
		hp_bar.position = Vector2(8, 106)
		hp_bar.size = Vector2(175, 14)
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		hp_bar.show_percentage = false
		card.add_child(hp_bar)
		var equipped: Dictionary = {}
		if typeof(_equipment_state.get("members")) == TYPE_ARRAY and index < (_equipment_state["members"] as Array).size():
			equipped = _equipment_state["members"][index]
		var icon_x := 8
		for slot in EquipmentService.MEMBER_SLOTS:
			var item: Dictionary = _definitions.get(String(equipped.get(slot, "")), {})
			var icon := TextureRect.new()
			icon.position = Vector2(icon_x, 128)
			icon.size = Vector2(36, 36)
			icon.texture = _assets.equipment_icon(int(item.get("icon_index", 0))) if not item.is_empty() else null
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icon.tooltip_text = "%s: %s" % [String(slot).capitalize(), String(item.get("display_name", "Empty"))]
			card.add_child(icon)
			icon_x += 45
		_party_box.add_child(panel)


func play_party_hit(effect: Dictionary) -> void:
	var index := int(effect.get("target_index", -1))
	if index < 0 or index >= _party_cards.size() or not is_instance_valid(_party_cards[index]):
		return
	var card := _party_cards[index]
	var portrait := _party_portraits[index]
	var damage_type := String(effect.get("damage_type", "impact"))
	var amount := int(effect.get("amount", 0))
	var blocked := int(effect.get("blocked", 0))
	var magnitude := clampf(float(effect.get("magnitude", 0.0)), 0.0, 1.0)
	var base_position := card.position
	var base_rotation := card.rotation
	var tween := create_tween()
	if damage_type == "healing":
		tween.tween_property(portrait, "modulate", Color("76ffd0"), 0.10)
		tween.tween_property(portrait, "modulate", Color.WHITE, 0.18)
		await tween.finished
		return
	if amount <= 0:
		if blocked > 0:
			tween.tween_property(portrait, "modulate", Color("9bdcff"), 0.06)
			tween.tween_property(portrait, "modulate", Color.WHITE, 0.10)
			await tween.finished
		return
	var amplitude := 1.0 + magnitude * 15.0
	var duration := 0.05 + magnitude * 0.08
	match damage_type:
		"electric":
			var flashes := 2 + ceili(magnitude * 4.0)
			for flash in range(flashes):
				var direction := -1.0 if flash % 2 == 0 else 1.0
				tween.tween_property(card, "position", base_position + Vector2(direction * amplitude, -amplitude * 0.35), duration * 0.55)
				tween.parallel().tween_property(portrait, "modulate", Color("78eaff") if flash % 2 == 0 else Color("fff6a6"), duration * 0.35)
				tween.parallel().tween_property(portrait, "rotation", direction * (0.02 + magnitude * 0.08), duration * 0.45)
		"slash":
			tween.tween_property(card, "position", base_position + Vector2(-amplitude, amplitude * 0.30), duration)
			tween.parallel().tween_property(portrait, "modulate", Color("ff8c8c"), duration)
			tween.parallel().tween_property(portrait, "rotation", -0.02 - magnitude * 0.08, duration)
		"decay", "acid":
			tween.tween_property(portrait, "modulate", Color("be75e7") if damage_type == "decay" else Color("93e866"), duration * 1.4)
			tween.parallel().tween_property(card, "position", base_position + Vector2(0, amplitude * 0.45), duration * 1.4)
		_:
			tween.tween_property(card, "position", base_position + Vector2(amplitude, 0), duration)
			tween.parallel().tween_property(portrait, "modulate", Color("ffc1a0"), duration)
			tween.tween_property(card, "position", base_position - Vector2(amplitude * 0.45, 0), duration * 0.7)
	tween.tween_property(card, "position", base_position, duration)
	tween.parallel().tween_property(portrait, "modulate", Color.WHITE, duration * 1.5)
	tween.parallel().tween_property(portrait, "rotation", base_rotation, duration)
	await tween.finished


func _update_enemies(enemies: Array, intents: Array, selected_target: int) -> void:
	_clear_children(_enemy_box)
	var heading := _simple_label("ENEMY INTENTIONS", 18, Color("f17882"))
	_enemy_box.add_child(heading)
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index]
		var button := Button.new()
		button.custom_minimum_size = Vector2(278, 62)
		button.text = "%s%s  |  HP %d / %d\n%s" % [
			"> " if index == selected_target else "",
			enemy["name"],
			int(enemy["hp"]),
			int(enemy["max_hp"]),
			_intent_text(intents, index),
		]
		button.disabled = int(enemy["hp"]) <= 0
		button.pressed.connect(_emit_target.bind(index))
		button.add_theme_font_size_override("font_size", 14)
		_enemy_box.add_child(button)


func _archive_rebuild_list() -> void:
	if _archive_list == null:
		return
	var previous := _archive_selected_id
	_archive_list.clear()
	var counts := {}
	for raw_id in _archive_inventory:
		var item_id := String(raw_id)
		counts[item_id] = int(counts.get(item_id, 0)) + 1
	var item_ids: Array = counts.keys()
	var favorites: Array = _equipment_state.get("favorites", [])
	item_ids.sort_custom(func(a: Variant, b: Variant) -> bool:
		var a_id := String(a)
		var b_id := String(b)
		var a_favorite := favorites.has(a_id)
		var b_favorite := favorites.has(b_id)
		if a_favorite != b_favorite:
			return a_favorite
		var a_item: Dictionary = _definitions.get(a_id, {})
		var b_item: Dictionary = _definitions.get(b_id, {})
		var a_rarity := int(RARITY_ORDER.get(String(a_item.get("rarity", "common")), 0))
		var b_rarity := int(RARITY_ORDER.get(String(b_item.get("rarity", "common")), 0))
		if a_rarity != b_rarity:
			return a_rarity > b_rarity
		return String(a_item.get("display_name", a_id)) < String(b_item.get("display_name", b_id))
	)
	var selected_row := -1
	for raw_id in item_ids:
		var item_id := String(raw_id)
		var item: Dictionary = _definitions.get(item_id, {})
		if item.is_empty() or not _archive_matches_filter(item, favorites.has(item_id)):
			continue
		var equipped_mark := "  [EQUIPPED]  |  " if _equipment.equipped_item_ids(_equipment_state).has(item_id) else ""
		var favorite_mark := "★ " if favorites.has(item_id) else ""
		var row := _archive_list.add_item("%s%s  x%d%s\n%s  |  %s" % [favorite_mark, item.get("display_name", item_id), counts[item_id], equipped_mark, String(item.get("rarity", "common")).to_upper(), String(item.get("slot", "archive")).to_upper()], _assets.equipment_icon(int(item.get("icon_index", 0))))
		_archive_list.set_item_metadata(row, item_id)
		_archive_list.set_item_custom_fg_color(row, Color(RARITY_COLORS.get(String(item.get("rarity", "common")), "#ffffff")))
		if item_id == previous:
			selected_row = row
	_archive_counter.text = "%d ENTRIES  |  %d UNIQUE" % [_archive_inventory.size(), counts.size()]
	if _archive_list.item_count > 0:
		if selected_row < 0:
			selected_row = 0
		_archive_list.select(selected_row)
		_archive_selected_id = String(_archive_list.get_item_metadata(selected_row))
		_archive_auto_destination()
	else:
		_archive_selected_id = ""
	_archive_update_details()


func _archive_matches_filter(item: Dictionary, favorite: bool) -> bool:
	match _archive_filter.selected:
		1:
			return favorite
		2:
			return String(item.get("role", "")) == "dena"
		3:
			return String(item.get("role", "")) == "moss"
		4:
			return String(item.get("role", "")) == "vell"
		5:
			return String(item.get("role", "")) == "ilex"
		6:
			return String(item.get("role", "")) == "shared"
		7:
			return not item.has("role")
		_:
			return true


func _archive_select_current() -> void:
	var selected := _archive_list.get_selected_items()
	if selected.is_empty():
		return
	_archive_selected_id = String(_archive_list.get_item_metadata(selected[0]))
	_archive_auto_destination()
	_archive_update_details()


func _archive_auto_destination() -> void:
	var item: Dictionary = _definitions.get(_archive_selected_id, {})
	var role := String(item.get("role", ""))
	var destination := EquipmentService.MEMBER_ROLES.find(role)
	if role == "shared":
		destination = 4
	if destination >= 0:
		_archive_destination.select(destination)


func _archive_update_details() -> void:
	var item: Dictionary = _definitions.get(_archive_selected_id, {})
	if item.is_empty():
		_archive_title.text = "NO ITEM SELECTED"
		_archive_details.text = ""
		_archive_comparison.text = ""
		_archive_equip_button.disabled = true
		return
	var rarity := String(item.get("rarity", "common"))
	_archive_title.text = "%s\n%s  |  %s" % [item.get("display_name", _archive_selected_id), rarity.to_upper(), String(item.get("slot", "archive")).to_upper()]
	_archive_title.add_theme_color_override("font_color", Color(RARITY_COLORS.get(rarity, "#ffffff")))
	_archive_icon.texture = _assets.equipment_icon(int(item.get("icon_index", 0)))
	_archive_details.text = "%s\n\n[color=#f2c86d][b]%s[/b][/color]\n%s" % [item.get("description", ""), item.get("power_id", "ARCHIVE-ONLY PROTOTYPE"), item.get("power_text", "This foundation reward has not yet been adapted to four-person equipment laws.")]
	var destination := _archive_destination.selected
	var destination_index := destination if destination < 4 else destination - 4
	var comparison := _equipment.item_comparison(item, _equipment_state, _definitions, destination_index)
	if comparison.is_empty():
		_archive_comparison.text = "No compatible item is currently equipped in this destination."
	else:
		_archive_comparison.text = "[color=#9fb0b5]%s[/color]\n%s\n\n[color=#f2c86d]%s[/color]" % [comparison.get("display_name", "Unknown"), comparison.get("power_text", ""), "Selecting EQUIP changes the law set immediately and never consumes either item."]
	var favorite := (_equipment_state.get("favorites", []) as Array).has(_archive_selected_id)
	_archive_favorite_button.text = "REMOVE FAVORITE" if favorite else "ADD FAVORITE"
	_archive_equip_button.disabled = not item.has("role")
	_archive_equip_button.text = "ARCHIVE ONLY" if not item.has("role") else "EQUIP TO DESTINATION"


func _archive_emit_equip() -> void:
	if _archive_selected_id.is_empty():
		return
	var item: Dictionary = _definitions.get(_archive_selected_id, {})
	if not item.has("role"):
		return
	var destination := _archive_destination.selected
	archive_equip_requested.emit(_archive_selected_id, "member" if destination < 4 else "relic", destination if destination < 4 else destination - 4)


func _command_prompt(party: Array, active_member: int, environment_primed: bool) -> String:
	if active_member < 0 or active_member >= party.size():
		return "Plan filed. Inspect intentions, then RESOLVE."
	var member: Dictionary = party[active_member]
	return "%s the %s  |  %s%s" % [member["name"], member["role"], member["power"], "  |  PRESSURE PRIMED" if environment_primed else ""]


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
	style.set_corner_radius_all(6)
	style.shadow_color = Color("00000099")
	style.shadow_size = 5
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


func _simple_label(text_value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
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
		"RESOLVE":
			return "#f3d487"
		"SYSTEM":
			return "#8aa5b5"
		_:
			return "#ffffff"
