extends Node2D
## 背景：三层夜色渐变 + 星空 + 月光 + 双层远山 + 大树剪影 + 垂藤灌木 + 浮尘微光。

const SKY_TOP := Color("#0c1a24")
const SKY_MID := Color("#0d1f1e")
const SKY_BOTTOM := Color("#0a150f")
const STAR := Color(0.75, 0.95, 0.85)
const HILL_FAR := Color("#0e2119")
const HILL_NEAR := Color("#112b1f")
const PLANT_DARK := Color("#0b1d13")
const PLANT_MID := Color("#0e2619")
const PLANT_LIGHT := Color("#123022")
const MOON := Color(0.82, 1.0, 0.9)
const MOTE := Color(0.7, 1.0, 0.75)

var _stars: Array[Vector2] = []
var _motes: Array[Vector2] = []


func _ready() -> void:
	# 确定性伪随机：星空与浮尘位置固定
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261025
	for i in 70:
		_stars.append(Vector2(rng.randf_range(0.0, 640.0), rng.randf_range(0.0, 210.0)))
	for i in 40:
		_motes.append(Vector2(rng.randf_range(0.0, 640.0), rng.randf_range(80.0, 340.0)))


func _draw() -> void:
	_draw_sky()
	# 星空（1~2 像素的小点）
	for i in _stars.size():
		var s := _stars[i]
		draw_rect(Rect2(s, Vector2.ONE * (1.0 + float(i % 2))), Color(STAR, 0.15 + (i % 3) * 0.12))
	# 月光
	_draw_glow(Vector2(140, 70), 80.0, Color(MOON, 0.06))
	draw_circle(Vector2(140, 70), 16.0, Color(MOON, 0.16))
	draw_circle(Vector2(140, 70), 13.0, Color(MOON, 0.22))
	# 双层远山
	_draw_ridge(HILL_FAR, 230.0, 34.0, 24.0, 0.0)
	_draw_ridge(HILL_NEAR, 275.0, 22.0, 18.0, 2.7)
	# 大树剪影（三层景深：暗 → 中 → 亮）
	_draw_tree(Vector2(90, 360), 210.0, PLANT_DARK)
	_draw_tree(Vector2(340, 360), 150.0, PLANT_MID)
	_draw_tree(Vector2(600, 360), 250.0, PLANT_LIGHT)
	# 顶部垂藤
	for x in range(10, 640, 26):
		_draw_vine_top(Vector2(x + float((x * 13) % 17), 0.0))
	# 地平线灌木
	for x in range(2, 640, 16):
		var p := Vector2(x + float((x * 7) % 11), 320.0)
		var c := PLANT_LIGHT if (x / 16) % 2 == 0 else PLANT_MID
		draw_circle(p + Vector2(0, -2.0), 3.0 + float((x * 5) % 4), c)
	# 浮尘微光
	for m in _motes:
		draw_circle(m, 1.2, Color(MOTE, 0.08))


func _draw_sky() -> void:
	# 三段渐变：用细横条近似
	var steps := 36
	for i in steps:
		var t := float(i) / (steps - 1)
		var color := SKY_TOP.lerp(SKY_MID, t) if t < 0.55 else SKY_MID.lerp(SKY_BOTTOM, (t - 0.55) / 0.45)
		draw_rect(Rect2(0, 360.0 * i / steps, 640, 360.0 / steps + 1), color)


func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	for i in 6:
		var t := float(i) / 5.0
		draw_circle(center, lerpf(radius * 0.3, radius, t), Color(color, color.a * (1.0 - t) * 0.5))


func _draw_ridge(color: Color, base: float, amp: float, step: float, seed_offset: float) -> void:
	# 双谐波起伏的有机山脊
	var pts := PackedVector2Array()
	pts.append(Vector2(-20, 400))
	var x := -20.0
	while x < 680:
		var y := base + sin(x * 0.013 + seed_offset) * amp + sin(x * 0.037 + seed_offset * 2.0) * amp * 0.4
		pts.append(Vector2(x, y))
		x += step
	pts.append(Vector2(680, 400))
	draw_colored_polygon(pts, color)


func _draw_tree(base: Vector2, height: float, color: Color) -> void:
	# 主干（带弯曲）
	draw_polyline(PackedVector2Array([
		base, base + Vector2(8, -height * 0.6), base + Vector2(-6, -height)]), color, 12.0)
	# 枝干
	draw_polyline(PackedVector2Array([
		base + Vector2(4, -height * 0.55), base + Vector2(-30, -height * 0.75)]), color, 6.0)
	draw_polyline(PackedVector2Array([
		base + Vector2(-2, -height * 0.75), base + Vector2(26, -height * 0.92)]), color, 5.0)
	# 顶部与枝头叶簇
	var top := base + Vector2(-6, -height)
	draw_circle(top, height * 0.16, color)
	draw_circle(top + Vector2(-18, 4), height * 0.13, color)
	draw_circle(top + Vector2(16, 2), height * 0.12, color)
	draw_circle(base + Vector2(-30, -height * 0.78), height * 0.09, color)
	draw_circle(base + Vector2(26, -height * 0.95), height * 0.08, color)
	# 从叶簇垂下的藤
	draw_line(top + Vector2(-10, 12), top + Vector2(-10, 12 + height * 0.2), color, 2.0)
	draw_line(top + Vector2(8, 14), top + Vector2(8, 14 + height * 0.16), color, 2.0)


func _draw_vine_top(at: Vector2) -> void:
	var h := 18.0 + float(int(at.x) % 5) * 6.0
	draw_line(at, at + Vector2(0, h), PLANT_MID, 1.5)
	draw_circle(at + Vector2(0, h), 2.4, PLANT_MID)
