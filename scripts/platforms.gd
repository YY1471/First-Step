extends Node2D
## 平台系统：根据 PLATFORMS / SLOPES 在运行时生成碰撞体并绘制外观。
## 改这两个数组即可调整关卡布局。

const FILL_WALL := Color("#10301f")        # 地面与墙体填充
const FILL_UNDER := Color("#0c2318")       # 地面下沿阴影
const PLATFORM_BODY := Color("#143a2c")    # 悬浮平台主体
const PLATFORM_EDGE := Color("#4fde8e")    # 平台顶部发光边缘
const GRASS := Color("#2a6b46")            # 草叶
const GRASS_HI := Color("#3d8f5e")         # 草叶亮色
const VINE := Color("#1e4a33")             # 垂藤
const VINE_LEAF := Color("#2f7a4c")
const WATER := Color("#16404e")            # 池塘水
const WATER_RIM := Color("#2f7d8a")
const LILY := Color("#2f6b46")
const MUSH_CAP := Color("#c98a5e")
const MUSH_CAP_HI := Color("#e0b080")
const MUSH_STEM := Color("#8a6a4a")

# 矩形平台（悬浮平台可被 S/↓ 下穿）
const PLATFORMS: Array[Rect2] = [
	Rect2(0, 320, 240, 80),     # 左侧平地（池塘所在）
	Rect2(480, 290, 160, 110),  # 右下低地
	Rect2(380, 206, 100, 14),   # B 中部步道（斜坡顶端）
	Rect2(90, 250, 70, 14),     # E 左中平台
	Rect2(170, 168, 60, 14),    # M 中高平台
	Rect2(20, 100, 70, 14),     # F 左上高台（观景点）
	Rect2(555, 136, 70, 14),    # D 右上高台（存档花所在）
	Rect2(-40, -40, 40, 420),   # 左墙
	Rect2(640, -40, 40, 420),   # 右墙
]

# 斜坡（三角形顶点，世界坐标；斜边为可行走表面）
var SLOPES: Array[PackedVector2Array] = [
	PackedVector2Array([Vector2(240, 320), Vector2(380, 206), Vector2(380, 320)]),
]


func _ready() -> void:
	for rect in PLATFORMS:
		var is_ground_wall := rect.size.y > 60.0
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		var collision := CollisionShape2D.new()
		collision.shape = shape
		collision.position = rect.size / 2.0
		var body := StaticBody2D.new()
		body.position = rect.position
		body.add_child(collision)
		if not is_ground_wall:
			# 悬浮平台：加入 group 供玩家按 S/↓ 下穿
			body.add_to_group("platform")
		add_child(body)
	for slope in SLOPES:
		var collision := CollisionPolygon2D.new()
		collision.polygon = slope
		var body := StaticBody2D.new()
		body.add_child(collision)
		add_child(body)


func _draw() -> void:
	# 地面与墙体
	for rect in PLATFORMS:
		if rect.size.y > 60.0:
			draw_rect(rect, FILL_WALL)
			draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 8), Vector2(rect.size.x, 8)), FILL_UNDER)
	# 斜坡
	for slope in SLOPES:
		draw_colored_polygon(slope, FILL_WALL)
		draw_line(slope[0], slope[1], GRASS, 2.0)
	# 悬浮平台：暗色主体 + 发光顶部边缘
	for rect in PLATFORMS:
		if rect.size.y <= 60.0:
			draw_rect(rect, PLATFORM_BODY)
			draw_rect(Rect2(rect.position + Vector2(3, 1), Vector2(rect.size.x - 6, 3)), PLATFORM_EDGE)
	# 左侧平地：顶部草线与草叶
	draw_rect(Rect2(0, 320, 240, 2), GRASS)
	for x in range(6, 240, 18):
		_draw_blade(Vector2(x + (x * 7) % 11, 320.0))
	# 斜坡草叶
	var slope_a := SLOPES[0][0]
	var slope_b := SLOPES[0][1]
	for i in 7:
		_draw_blade(slope_a.lerp(slope_b, (i + 0.5) / 7.0) + Vector2(0, -1))
	# 池塘与芦苇
	_draw_pond(Vector2(105, 322))
	# 蘑菇
	_draw_mushrooms(Vector2(26, 320), 1.0)
	_draw_mushrooms(Vector2(216, 320), 0.7)
	# 平台垂藤
	_draw_vine(Vector2(120, 264), 26.0)
	_draw_vine(Vector2(200, 182), 34.0)
	_draw_vine(Vector2(420, 220), 30.0)
	# 右上高台与右下低地的草线
	draw_rect(Rect2(555, 136, 70, 2), GRASS)
	draw_rect(Rect2(480, 290, 160, 2), GRASS)


func _draw_blade(base: Vector2) -> void:
	var h := 5.0 + float(int(base.x) % 3) * 2.0
	var tip := base + Vector2(2.0, -h)
	draw_colored_polygon(PackedVector2Array([base, tip, tip + Vector2(-3, 0)]), GRASS if int(base.x) % 2 == 0 else GRASS_HI)


func _draw_pond(center: Vector2) -> void:
	# 水面（压扁的椭圆）
	draw_set_transform(center, 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, 52.0, WATER_RIM)
	draw_circle(Vector2.ZERO, 45.0, WATER)
	draw_set_transform(Vector2.ZERO)
	# 高光
	draw_circle(center + Vector2(-18, -3), 10.0, Color(WATER_RIM, 0.35))
	# 睡莲叶
	draw_circle(center + Vector2(-30, 1), 5.0, LILY)
	draw_circle(center + Vector2(26, 2), 4.0, LILY)
	# 芦苇
	for reed in [Vector2(52, 318), Vector2(105, 316), Vector2(152, 318)]:
		var h := 18.0 + float(int(reed.x) % 3) * 6.0
		draw_line(reed, reed + Vector2(0, -h), GRASS, 1.5)
		draw_set_transform(reed + Vector2(0, -h), 0.0, Vector2.ONE)
		draw_circle(Vector2(-2, 0), 1.8, GRASS_HI)
		draw_set_transform(Vector2.ZERO)


func _draw_mushrooms(base: Vector2, s: float) -> void:
	draw_rect(Rect2(base + Vector2(-3 * s, -8 * s), Vector2(3 * s, 8 * s)), MUSH_STEM)
	draw_circle(base + Vector2(-1.5 * s, -9 * s), 5 * s, MUSH_CAP)
	draw_circle(base + Vector2(-3.5 * s, -11 * s), 1.6 * s, MUSH_CAP_HI)
	draw_rect(Rect2(base + Vector2(6 * s, -5 * s), Vector2(2 * s, 5 * s)), MUSH_STEM)
	draw_circle(base + Vector2(7 * s, -7 * s), 3.4 * s, MUSH_CAP)
	draw_circle(base + Vector2(5.8 * s, -8.4 * s), 1.1 * s, MUSH_CAP_HI)


func _draw_vine(top: Vector2, length: float) -> void:
	draw_line(top, top + Vector2(0, length), VINE, 1.5)
	for k in 3:
		var p := top + Vector2(0, length * (k + 0.5) / 3.0)
		var side := 1.0 if k % 2 == 0 else -1.0
		draw_circle(p + Vector2(side * 3.0, 0), 2.2, VINE_LEAF)
