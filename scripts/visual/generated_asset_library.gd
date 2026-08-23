class_name GeneratedAssetLibrary
extends RefCounted

const PARTY_PATH := "res://assets/generated/party_portraits.png"
const ENEMY_PATH := "res://assets/generated/crawler_enemies.png"
const ICON_PATH := "res://assets/generated/equipment_icons.png"
const MATERIAL_PATH := "res://assets/generated/dungeon_materials.png"

var _party_cache: Dictionary = {}
var _enemy_cache: Dictionary = {}
var _icon_cache: Dictionary = {}
var _material_cache: Dictionary = {}


func party_portrait(member_index: int) -> ImageTexture:
	var safe_index := clampi(member_index, 0, 3)
	if not _party_cache.has(safe_index):
		_party_cache[safe_index] = _sheet_region(PARTY_PATH, 2, 2, safe_index, true)
	return _party_cache[safe_index] as ImageTexture


func enemy_portrait(sprite_key: String) -> ImageTexture:
	var index: int = int({"filing_larva": 0, "pipe_goblin": 1, "form_auditor": 2}.get(sprite_key, 0))
	if not _enemy_cache.has(index):
		_enemy_cache[index] = _sheet_region(ENEMY_PATH, 3, 1, index, true)
	return _enemy_cache[index] as ImageTexture


func equipment_icon(icon_index: int) -> ImageTexture:
	var safe_index := clampi(icon_index, 0, 15)
	if not _icon_cache.has(safe_index):
		_icon_cache[safe_index] = _sheet_region(ICON_PATH, 4, 4, safe_index, true)
	return _icon_cache[safe_index] as ImageTexture


func dungeon_material(material_index: int) -> ImageTexture:
	var safe_index := clampi(material_index, 0, 3)
	if not _material_cache.has(safe_index):
		_material_cache[safe_index] = _sheet_region(MATERIAL_PATH, 2, 2, safe_index, false)
	return _material_cache[safe_index] as ImageTexture


func _sheet_region(path: String, columns: int, rows: int, index: int, remove_checker: bool) -> ImageTexture:
	var source_texture := load(path) as Texture2D
	if source_texture == null:
		return ImageTexture.new()
	var source: Image = source_texture.get_image()
	var column: int = index % columns
	var row: int = index / columns
	var x0: int = roundi(float(column) * float(source.get_width()) / float(columns))
	var x1: int = roundi(float(column + 1) * float(source.get_width()) / float(columns))
	var y0: int = roundi(float(row) * float(source.get_height()) / float(rows))
	var y1: int = roundi(float(row + 1) * float(source.get_height()) / float(rows))
	var region: Image = source.get_region(Rect2i(x0, y0, x1 - x0, y1 - y0))
	region.convert(Image.FORMAT_RGBA8)
	if remove_checker:
		_remove_baked_checker(region)
	return ImageTexture.create_from_image(region)


func _remove_baked_checker(image: Image) -> void:
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			var high: float = maxf(color.r, maxf(color.g, color.b))
			var low: float = minf(color.r, minf(color.g, color.b))
			var neutral: float = high - low
			if low > 0.78 and neutral < 0.055:
				color.a = 0.0
				image.set_pixel(x, y, color)
