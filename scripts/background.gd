extends Node2D
## 背景：渐变夜色 + 巨大植物剪影 + 微光，营造《动物井》式的幽静氛围。

const SKY_TOP := Color("#0d1c26")
const SKY_BOTTOM := Color("#0a150f")
const HILL_FAR := Color("#0f241a")
const HILL_NEAR := Color("#122d21")
const PLANT_DARK := Color("#0c1f15")
const PLANT_MID := Color("#103023")
const MOON := Color(0.85, 1.0, 0.9)


func _draw() -> void:
	_draw_sky()
	_draw_glow(Vector2(150, 60), 90.0, Color(MOON, 0.05))  # 微弱的“月光”
	_draw_hills(HILL_FAR, 240.0, 28.0, 60.0)
	_draw_giant_plant(Vector2(80, 360), 230.0, PLANT_DARK)
	_draw_giant_plant(Vector2(590, 360), 300.0, PLANT_DARK)
	_draw_hills(HILL_NEAR, 290.0, 20.0, 40.0)
	_draw_giant_plant(Vector2(330, 360), 170.0, PLANT_MID)


func _draw_sky() -> void:
	# 竖直渐变：用细横条近似
	var steps := 30
	for i in steps:
		var t := float(i) / (steps - 1)
		var color := SKY_TOP.lerp(SKY_BOTTOM, t)
		draw_rect(Rect2(0, 360.0 * i / steps, 640, 360.0 / steps + 1), color)


func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	for i in 6:
		var t := float(i) / 5.0
		draw_circle(center, lerpf(radius * 0.3, radius, t), Color(color, color.a * (1.0 - t) * 0.5))


func _draw_hills(color: Color, base_y: float, amp: float, width: float) -> void:
	var pts := PackedVector2Array()
	pts.append(Vector2(-20, 360))
	var x := -20.0
	while x < 680:
		pts.append(Vector2(x, base_y + sin(x * 0.011) * amp))
		x += width
	pts.append(Vector2(680, 360))
	draw_colored_polygon(pts, color)


func _draw_giant_plant(base: Vector2, height: float, color: Color) -> void:
	# 主干
	draw_polyline(PackedVector2Array([base, base + Vector2(0, -height), base + Vector2(30, -height * 0.82)]), color, 14.0)
	# 顶部大叶片簇
	var top := base + Vector2(0, -height)
	draw_circle(top + Vector2(-14, 2), 26.0, color)
	draw_circle(top + Vector2(16, 4), 22.0, color)
	draw_circle(top + Vector2(2, -8), 18.0, color)
	# 侧枝
	var mid := base + Vector2(0, -height * 0.55)
	draw_polyline(PackedVector2Array([mid, mid + Vector2(42, -26)]), color, 8.0)
	draw_circle(mid + Vector2(48, -32), 12.0, color)
