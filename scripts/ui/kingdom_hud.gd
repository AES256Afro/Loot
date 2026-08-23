class_name KingdomHUD
extends CanvasLayer

signal travel_requested(q: int, r: int)
signal site_action_requested(site_id: String, action: String)
signal town_exit_requested
signal town_location_action_requested(location_id: String)
signal service_choice_selected(action: String, payload: Dictionary)

const REFERENCE_SIZE := Vector2(1600, 900)

var _root: Control
var _title: Label
var _subtitle: Label
var _resource_line: Label
var _archive_line: Label
var _map_view: HexMapView
var _town_view: TownMapView
var _map_heading: Label
var _detail_title: Label
var _detail_tags: Label
var _detail_body: RichTextLabel
var _actions: VBoxContainer
var _footer: Label
var _service_modal: PanelContainer
var _service_title: Label
var _service_subtitle: Label
var _service_body: RichTextLabel
var _service_actions: VBoxContainer
var _definition: Dictionary = {}
var _state: Dictionary = {}
var _cells: Array = []
var _selected_site: Dictionary = {}
var _selected_location: Dictionary = {}
var _mode := "kingdom"


func _ready() -> void:
	_build_interface()
	hide_all()


func show_kingdom(definition: Dictionary, cells: Array, state: Dictionary, archive_count: int) -> void:
	_definition = definition.duplicate(true)
	_cells = cells.duplicate(true)
	_state = state.duplicate(true)
	_mode = "kingdom"
	_root.show()
	_service_modal.hide()
	_map_view.show()
	_town_view.hide()
	var kingdom: Dictionary = _definition.get("kingdom", {})
	_title.text = String(kingdom.get("display_name", "KINGDOM MAP")).to_upper()
	_subtitle.text = String(kingdom.get("subtitle", "Persistent regional travel"))
	_map_heading.text = "STRATEGIC KINGDOM MAP  |  DISCOVERY PERSISTS"
	_archive_line.text = "ARCHIVE %d  |  NO CAPACITY LIMIT" % archive_count
	_refresh_resources()
	_map_view.set_map(_cells, _definition.get("sites", []), _state)
	_select_hex(Vector2i(int(_state.get("selected_q", _state.get("q", 0))), int(_state.get("selected_r", _state.get("r", 0)))))
	_footer.text = "Click any hex to inspect  |  Travel has no movement-point cap  |  Sites and unresolved events do not expire  |  F5 save  F9 load"


func show_town(definition: Dictionary, state: Dictionary, archive_count: int) -> void:
	_definition = definition.duplicate(true)
	_state = state.duplicate(true)
	_mode = "town"
	_root.show()
	_service_modal.hide()
	_map_view.hide()
	_town_view.show()
	var town: Dictionary = _definition.get("town", {})
	_title.text = String(town.get("display_name", "TOWN")).to_upper()
	_subtitle.text = String(town.get("subtitle", "Safe settlement"))
	_map_heading.text = "TOP-DOWN SETTLEMENT MAP  |  WALK OR CLICK TO MOVE"
	_archive_line.text = "ARCHIVE %d  |  PURCHASES FILE DIRECTLY" % archive_count
	_refresh_resources()
	var locations: Array = town.get("locations", [])
	var selected_id := String(_selected_location.get("id", ""))
	_town_view.set_town(locations, _state.get("town_position", {}), selected_id)
	if _selected_location.is_empty() and not locations.is_empty():
		_select_location(String((locations[0] as Dictionary).get("id", "")))
	else:
		_render_location_detail()
	_footer.text = "WASD / arrows walk  |  Click a building to approach  |  E enters a nearby service  |  EXIT returns to the exact kingdom hex"


func show_service(title_text: String, subtitle_text: String, body_text: String, options: Array) -> void:
	_service_title.text = title_text
	_service_subtitle.text = subtitle_text
	_service_body.text = body_text
	_clear_children(_service_actions)
	var first_enabled: Button
	for raw_option in options:
		if typeof(raw_option) != TYPE_DICTIONARY:
			continue
		var option: Dictionary = raw_option
		var button := _button(String(option.get("label", "CONTINUE")), Vector2(760, 52))
		button.disabled = bool(option.get("disabled", false))
		button.tooltip_text = String(option.get("tooltip", ""))
		button.pressed.connect(_emit_service_choice.bind(String(option.get("action", "close")), option.get("payload", {})))
		_service_actions.add_child(button)
		if first_enabled == null and not button.disabled:
			first_enabled = button
	_service_modal.show()
	if first_enabled != null:
		first_enabled.grab_focus()


func hide_service() -> void:
	_service_modal.hide()


func hide_all() -> void:
	if _root != null:
		_root.hide()


func is_world_visible() -> bool:
	return _root != null and _root.visible


func service_is_open() -> bool:
	return _service_modal != null and _service_modal.visible


func town_position() -> Dictionary:
	return _town_view.get_party_position() if _town_view != null else _state.get("town_position", {})


func _build_interface() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("071116")
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(background)

	var top := _panel(_root, Rect2(18, 14, 1564, 84), Color("0d2027"), Color("668c84"), 2)
	var top_content := _absolute_content(top)
	_title = _label(top_content, Rect2(22, 9, 810, 38), 30, Color("f1d27b"))
	_subtitle = _label(top_content, Rect2(24, 47, 850, 24), 15, Color("91cfc6"))
	_resource_line = _label(top_content, Rect2(850, 12, 680, 28), 17, Color("e6d7ab"))
	_resource_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_archive_line = _label(top_content, Rect2(900, 48, 630, 22), 14, Color("a7b9bb"))
	_archive_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	var map_panel := _panel(_root, Rect2(18, 112, 1160, 726), Color("0a171c"), Color("365a57"), 2)
	var map_content := _absolute_content(map_panel)
	_map_heading = _label(map_content, Rect2(18, 9, 1118, 28), 17, Color("77d8c9"))
	_map_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_map_view = HexMapView.new()
	_map_view.position = Vector2(10, 42)
	_map_view.size = Vector2(1140, 674)
	_map_view.hex_selected.connect(_select_hex_from_signal)
	map_content.add_child(_map_view)
	_town_view = TownMapView.new()
	_town_view.position = Vector2(10, 42)
	_town_view.size = Vector2(1140, 674)
	_town_view.location_selected.connect(_select_location)
	_town_view.interact_requested.connect(_on_town_interact)
	map_content.add_child(_town_view)

	var detail_panel := _panel(_root, Rect2(1192, 112, 390, 726), Color("101d23"), Color("6d6650"), 2)
	var detail_content := _absolute_content(detail_panel)
	_detail_title = _label(detail_content, Rect2(20, 18, 350, 72), 25, Color("f0ce74"))
	_detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_tags = _label(detail_content, Rect2(20, 94, 350, 50), 14, Color("76d7c9"))
	_detail_tags.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_body = RichTextLabel.new()
	_detail_body.position = Vector2(20, 150)
	_detail_body.size = Vector2(350, 298)
	_detail_body.bbcode_enabled = true
	_detail_body.add_theme_font_size_override("normal_font_size", 17)
	_detail_body.add_theme_font_size_override("bold_font_size", 17)
	_detail_body.add_theme_color_override("default_color", Color("d6dfdc"))
	detail_content.add_child(_detail_body)
	_actions = VBoxContainer.new()
	_actions.position = Vector2(20, 466)
	_actions.size = Vector2(350, 218)
	_actions.add_theme_constant_override("separation", 9)
	detail_content.add_child(_actions)

	_footer = _label(_root, Rect2(18, 852, 1564, 32), 14, Color("98aaad"))
	_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_service_modal = _build_service_modal(_root)


func _build_service_modal(parent: Control) -> PanelContainer:
	var modal := _panel(parent, Rect2(330, 82, 940, 736), Color("09161cfb"), Color("d0a959"), 4)
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	var content := _absolute_content(modal)
	_service_title = _label(content, Rect2(34, 24, 872, 50), 32, Color("f1cf74"))
	_service_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_service_subtitle = _label(content, Rect2(34, 78, 872, 30), 16, Color("79d8ca"))
	_service_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_service_body = RichTextLabel.new()
	_service_body.position = Vector2(54, 124)
	_service_body.size = Vector2(832, 222)
	_service_body.bbcode_enabled = true
	_service_body.add_theme_font_size_override("normal_font_size", 18)
	_service_body.add_theme_font_size_override("bold_font_size", 18)
	_service_body.add_theme_color_override("default_color", Color("dce3df"))
	content.add_child(_service_body)
	_service_actions = VBoxContainer.new()
	_service_actions.position = Vector2(90, 358)
	_service_actions.size = Vector2(760, 346)
	_service_actions.add_theme_constant_override("separation", 8)
	content.add_child(_service_actions)
	return modal


func _select_hex_from_signal(q: int, r: int) -> void:
	_select_hex(Vector2i(q, r))


func _select_hex(coord: Vector2i) -> void:
	_state["selected_q"] = coord.x
	_state["selected_r"] = coord.y
	_map_view.set_map(_cells, _definition.get("sites", []), _state)
	_selected_site = _site_at(coord)
	_clear_children(_actions)
	var current := Vector2i(int(_state.get("q", 0)), int(_state.get("r", 0)))
	if not _is_discovered(coord):
		_detail_title.text = "UNSURVEYED HEX"
		_detail_tags.text = "FOG OF INFORMATION  |  POSITION %d,%d" % [coord.x, coord.y]
		_detail_body.text = "Travel reveals nearby terrain and map provenance. There is no movement-point allowance and no end-turn requirement."
	else:
		var cell := _cell_at(coord)
		if _selected_site.is_empty():
			_detail_title.text = String(cell.get("terrain", "frontier")).replace("_", " ").capitalize()
			_detail_tags.text = "%s JURISDICTION  |  HEX %d,%d" % [String(cell.get("jurisdiction", "unknown")).replace("_", " ").to_upper(), coord.x, coord.y]
			_detail_body.text = "[color=#aab8b9]No named site is filed on this hex.[/color]\n\nTravel remains useful for revealing routes, ecological borders, resources, events, and future kingdom gates."
		else:
			_detail_title.text = String(_selected_site.get("display_name", "UNKNOWN SITE"))
			_detail_tags.text = "%s  |  %s  |  %s" % [String(_selected_site.get("type", "site")).to_upper(), String(_selected_site.get("safety", "unknown")).to_upper(), String(_selected_site.get("provenance", "unverified")).to_upper()]
			_detail_body.text = "%s\n\n[color=#9eb1b3]Safety and information provenance are visible before commitment.[/color]" % String(_selected_site.get("description", ""))
	if coord != current:
		var travel := _button("TRAVEL TO HEX  %d,%d" % [coord.x, coord.y], Vector2(350, 48))
		travel.pressed.connect(func() -> void: travel_requested.emit(coord.x, coord.y))
		_actions.add_child(travel)
	else:
		_add_site_actions()
	var reset := _button("CENTER ON PARTY", Vector2(350, 42))
	reset.pressed.connect(func() -> void: _select_hex(Vector2i(int(_state.get("q", 0)), int(_state.get("r", 0)))))
	_actions.add_child(reset)


func _add_site_actions() -> void:
	if _selected_site.is_empty():
		return
	for raw_action in _selected_site.get("actions", []):
		var action := String(raw_action)
		var button := _button(_action_label(action), Vector2(350, 46))
		button.pressed.connect(func() -> void: site_action_requested.emit(String(_selected_site.get("id", "")), action))
		_actions.add_child(button)


func _select_location(location_id: String) -> void:
	_selected_location = _location_by_id(location_id)
	_town_view.selected_location_id = location_id
	_town_view.queue_redraw()
	_render_location_detail()


func _render_location_detail() -> void:
	_clear_children(_actions)
	if _selected_location.is_empty():
		_detail_title.text = "LATCHMARKET EDGE"
		_detail_tags.text = "SAFE SETTLEMENT"
		_detail_body.text = "Choose a named location."
		return
	_detail_title.text = String(_selected_location.get("display_name", "TOWN LOCATION"))
	_detail_tags.text = "%s  |  VISIBLE SERVICE" % String(_selected_location.get("type", "social")).to_upper()
	_detail_body.text = "%s\n\n[color=#9eb1b3]Walking is atmospheric, not a stamina gate. The side-panel button is an accessibility shortcut.[/color]" % String(_selected_location.get("description", ""))
	var enter := _button("ENTER SELECTED LOCATION", Vector2(350, 50))
	enter.pressed.connect(func() -> void: town_location_action_requested.emit(String(_selected_location.get("id", ""))))
	_actions.add_child(enter)
	var exit := _button("EXIT TO KINGDOM MAP", Vector2(350, 50))
	exit.pressed.connect(func() -> void: town_exit_requested.emit())
	_actions.add_child(exit)


func _on_town_interact(location_id: String) -> void:
	_select_location(location_id)
	town_location_action_requested.emit(location_id)


func _emit_service_choice(action: String, payload_value: Variant) -> void:
	var payload: Dictionary = payload_value if typeof(payload_value) == TYPE_DICTIONARY else {}
	service_choice_selected.emit(action, payload)


func _refresh_resources() -> void:
	var resources: Dictionary = _state.get("resources", {})
	_resource_line.text = "MARKS %d  |  SALVAGE %d  |  SPORE GLASS %d  |  SEALS %d  |  PULSE %d" % [
		int(resources.get("marks", 0)),
		int(resources.get("salvage", 0)),
		int(resources.get("spore_glass", 0)),
		int(resources.get("route_seals", 0)),
		int(_state.get("strategic_pulse", 0)),
	]


func _site_at(coord: Vector2i) -> Dictionary:
	for raw_site in _definition.get("sites", []):
		var site: Dictionary = raw_site
		if int(site.get("q", -1)) == coord.x and int(site.get("r", -1)) == coord.y:
			return site.duplicate(true)
	return {}


func _cell_at(coord: Vector2i) -> Dictionary:
	for raw_cell in _cells:
		var cell: Dictionary = raw_cell
		if int(cell.get("q", -1)) == coord.x and int(cell.get("r", -1)) == coord.y:
			return cell
	return {}


func _location_by_id(location_id: String) -> Dictionary:
	for raw_location in (_definition.get("town", {}) as Dictionary).get("locations", []):
		var location: Dictionary = raw_location
		if String(location.get("id", "")) == location_id:
			return location.duplicate(true)
	return {}


func _is_discovered(coord: Vector2i) -> bool:
	return (_state.get("discovered", []) as Array).has("%d,%d" % [coord.x, coord.y])


func _action_label(action: String) -> String:
	match action:
		"enter_hearthfold": return "ENTER THE HEARTHFOLD"
		"enter_town": return "ENTER LATCHMARKET EDGE"
		"claim_resource": return "COLLECT REGIONAL RESOURCE"
		"inspect_event": return "INSPECT PERSISTENT EVENT"
		"enter_dungeon": return "ENTER FIRST-PERSON DUNGEON"
		"discover_lore": return "REQUEST LORE SAUCE"
		"inspect_social": return "VISIT CARAVAN REST"
		"inspect_shrine": return "INSPECT SHRINE"
		"inspect_border": return "INSPECT KINGDOM BORDER"
		_: return action.replace("_", " ").to_upper()


func _panel(parent: Control, rect: Rect2, background: Color, border: Color, width: int = 2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = rect.position
	panel.size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(5)
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


func _absolute_content(parent: Control) -> Control:
	var content := Control.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(content)
	return content


func _button(text_value: String, minimum_size: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = minimum_size
	button.add_theme_font_size_override("font_size", 16)
	return button


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
