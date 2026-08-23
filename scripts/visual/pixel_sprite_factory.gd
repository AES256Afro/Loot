class_name PixelSpriteFactory
extends RefCounted

const WIDTH := 32
const HEIGHT := 40


func enemy_texture(sprite_key: String) -> ImageTexture:
	var image := Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	match sprite_key:
		"pipe_goblin":
			_draw_pipe_goblin(image)
		"form_auditor":
			_draw_form_auditor(image)
		_:
			_draw_filing_larva(image)
	return ImageTexture.create_from_image(image)


func picket_texture() -> ImageTexture:
	var image := Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_circle(image, Vector2i(16, 12), 7, Color("33251f"))
	_circle(image, Vector2i(16, 12), 5, Color("ba7b32"))
	_rect(image, Rect2i(10, 18, 12, 14), Color("3a2821"))
	_rect(image, Rect2i(12, 19, 8, 12), Color("c58b3e"))
	_rect(image, Rect2i(13, 10, 2, 2), Color("77f5e5"))
	_rect(image, Rect2i(18, 10, 2, 2), Color("77f5e5"))
	_rect(image, Rect2i(14, 15, 5, 1), Color("5e3828"))
	_rect(image, Rect2i(7, 21, 3, 9), Color("9b642d"))
	_rect(image, Rect2i(22, 21, 3, 9), Color("9b642d"))
	_rect(image, Rect2i(11, 32, 4, 5), Color("684126"))
	_rect(image, Rect2i(18, 32, 4, 5), Color("684126"))
	return ImageTexture.create_from_image(image)


func _draw_filing_larva(image: Image) -> void:
	_circle(image, Vector2i(16, 23), 10, Color("16221b"))
	_circle(image, Vector2i(16, 22), 8, Color("5f8d4d"))
	_circle(image, Vector2i(13, 19), 2, Color("d6ef9b"))
	_circle(image, Vector2i(20, 19), 2, Color("d6ef9b"))
	_rect(image, Rect2i(11, 24, 11, 3), Color("243629"))
	_rect(image, Rect2i(13, 24, 2, 2), Color("f1e8c3"))
	_rect(image, Rect2i(18, 24, 2, 2), Color("f1e8c3"))
	_rect(image, Rect2i(8, 12, 16, 4), Color("ded2a9"))
	_rect(image, Rect2i(10, 10, 12, 2), Color("827455"))
	_rect(image, Rect2i(7, 31, 6, 3), Color("3f663b"))
	_rect(image, Rect2i(20, 31, 6, 3), Color("3f663b"))
	_rect(image, Rect2i(12, 15, 3, 2), Color("8fbb67"))


func _draw_pipe_goblin(image: Image) -> void:
	_rect(image, Rect2i(9, 17, 14, 17), Color("281d19"))
	_circle(image, Vector2i(16, 16), 8, Color("263328"))
	_circle(image, Vector2i(16, 16), 6, Color("779156"))
	_rect(image, Rect2i(6, 13, 5, 3), Color("5c713e"))
	_rect(image, Rect2i(22, 13, 5, 3), Color("5c713e"))
	_rect(image, Rect2i(12, 14, 2, 2), Color("f4c84b"))
	_rect(image, Rect2i(19, 14, 2, 2), Color("f4c84b"))
	_rect(image, Rect2i(13, 20, 7, 2), Color("30251f"))
	_rect(image, Rect2i(12, 25, 9, 7), Color("a95c2f"))
	_rect(image, Rect2i(5, 21, 4, 13), Color("6a4128"))
	_rect(image, Rect2i(24, 18, 2, 18), Color("b6a06d"))
	_rect(image, Rect2i(22, 18, 6, 3), Color("d1bf8b"))
	_rect(image, Rect2i(11, 34, 4, 4), Color("3f3025"))
	_rect(image, Rect2i(18, 34, 4, 4), Color("3f3025"))


func _draw_form_auditor(image: Image) -> void:
	_rect(image, Rect2i(8, 18, 17, 17), Color("241b27"))
	_circle(image, Vector2i(16, 17), 7, Color("d1a477"))
	_circle(image, Vector2i(16, 10), 11, Color("2b172d"))
	_circle(image, Vector2i(16, 9), 9, Color("8b356f"))
	_rect(image, Rect2i(8, 10, 17, 5), Color("a84782"))
	_rect(image, Rect2i(12, 17, 2, 2), Color("2a1b24"))
	_rect(image, Rect2i(19, 17, 2, 2), Color("2a1b24"))
	_rect(image, Rect2i(13, 22, 7, 2), Color("5b342c"))
	_rect(image, Rect2i(10, 25, 13, 9), Color("5b2e67"))
	_rect(image, Rect2i(23, 22, 7, 12), Color("6b4c2e"))
	_rect(image, Rect2i(24, 23, 5, 9), Color("d8c79c"))
	_rect(image, Rect2i(5, 23, 4, 11), Color("ad783b"))
	_circle(image, Vector2i(6, 22), 3, Color("e1b54f"))
	_rect(image, Rect2i(10, 35, 5, 4), Color("3b253c"))
	_rect(image, Rect2i(19, 35, 5, 4), Color("3b253c"))
	_rect(image, Rect2i(11, 5, 3, 2), Color("d86baa"))


func _rect(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(maxi(0, rect.position.y), mini(HEIGHT, rect.end.y)):
		for x in range(maxi(0, rect.position.x), mini(WIDTH, rect.end.x)):
			image.set_pixel(x, y, color)


func _circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			if x < 0 or y < 0 or x >= WIDTH or y >= HEIGHT:
				continue
			var delta := Vector2i(x, y) - center
			if delta.x * delta.x + delta.y * delta.y <= radius * radius:
				image.set_pixel(x, y, color)
