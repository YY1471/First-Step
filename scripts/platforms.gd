extends Node2D
## 平台系统：根据 PLATFORMS 里的矩形在运行时生成碰撞体，并负责绘制外观。
## 改 PLATFORMS 数组即可调整关卡布局。

const FILL_WALL := Color("#10301f")        # 地面与墙体的填充色
const PLATFORM_BODY := Color("#143a2c")    # 悬浮平台主体
const PLATFORM_EDGE := Color("#4fde8e")    # 平台顶部发光边缘
const BLADE_COLOR := Color("#2a6b46")      # 草叶
const FLOWER_GLOW := Color(0.75, 1.0, 0.55)

# 跳跃最大高度约 112px，平台间高度差需小于该值；
# 相邻平台不得水平重叠且垂直间距过近，否则起跳会撞到上方平台底部。
const PLATFORMS: Array[Rect2] = [
	Rect2(0, 320, 640, 80),    # 地面
	Rect2(90, 250, 100, 14),   # A 台阶（出生点）
	Rect2(210, 160, 90, 14),   # M 左中平台
	Rect2(40, 70, 80, 14),     # E 左上高台
	Rect2(300, 200, 100, 14),  # B 中部平台
	Rect2(450, 140, 90, 14),   # C 右中平台
	Rect2(560, 60, 80, 14),    # D 右上高台（发光花所在）
	Rect2(-40, -40, 40, 420),  # 左墙
	Rect2(640, -40, 40, 420),  # 右墙
]


func _ready() -> void:
	for rect in PLATFORMS:
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		var collision := CollisionShape2D.new()
		collision.shape = shape
		collision.position = rect.size / 2.0
		var body := StaticBody2D.new()
		body.position = rect.position
		body.add_child(collision)
		add_child(body)


func _draw() -> void:
	for rect in PLATFORMS:
		if rect.size.y > 60.0:  # 地面与墙体：整块填充
			draw_rect(rect, FILL_WALL)
		else:                   # 悬浮平台：暗色主体 + 发光顶部边缘
			draw_rect(rect, PLATFORM_BODY)
			draw_rect(Rect2(rect.position + Vector2(3, 1), Vector2(rect.size.x - 6, 3)), PLATFORM_EDGE)
	# 地面顶部一线微光
	draw_rect(Rect2(0, 320, 640, 2), BLADE_COLOR)
	# 地面上的草叶
	for x in range(8, 640, 22):
		_draw_blade(Vector2(x + (x * 7) % 11, 320.0))
	# 高台上的发光花
	_draw_flower(Vector2(600, 60))


func _draw_blade(base: Vector2) -> void:
	var h := 5.0 + float(int(base.x) % 3) * 2.0
	var tip := base + Vector2(2.0, -h)
	draw_colored_polygon(PackedVector2Array([base, tip, tip + Vector2(-3, 0)]), BLADE_COLOR)


func _draw_flower(at: Vector2) -> void:
	# 光晕
	for i in 4:
		var t := 1.0 - float(i) / 4.0
		draw_circle(at, lerpf(6.0, 20.0, t), Color(FLOWER_GLOW, 0.05 + 0.04 * t))
	# 花茎与花
	draw_line(at + Vector2(0, 6), at + Vector2(0, -2), PLATFORM_EDGE, 2.0)
	draw_circle(at + Vector2(0, -4), 3.0, Color("#d8ffb0"))
	for k in 5:
		var ang := TAU * k / 5.0
		draw_circle(at + Vector2(0, -4) + Vector2.from_angle(ang) * 5.0, 2.0, Color("#9fffd0"))
