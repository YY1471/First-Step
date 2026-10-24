extends Node2D
## 纯代码绘制的角色形象：一颗长着嫩芽的种子团子（植物版动物井小团子）。

const BODY_COLOR := Color("#8fdc55")
const BODY_DARK := Color("#1a3a24")
const BELLY_COLOR := Color("#b6f57c")
const EYE_COLOR := Color("#12301f")
const SPROUT_COLOR := Color("#4fde8e")

var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	var player := get_parent() as CharacterBody2D

	# 上升拉长 / 下落压扁（挤压与拉伸）
	var stretch := clampf(player.velocity.y / 600.0, -0.35, 0.35)
	scale.x = (1.0 - stretch * 0.45) * player.facing
	scale.y = 1.0 + stretch * 0.45
	# 待机时轻微呼吸
	if player.is_on_floor() and absf(player.velocity.x) < 10.0:
		scale.x *= 1.0 + sin(_time * 3.0) * 0.015
		scale.y *= 1.0 - sin(_time * 3.0) * 0.015
	queue_redraw()


func _draw() -> void:
	var sway := sin(_time * 2.0) * 0.12

	# 身体（椭圆团子）
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.88))
	draw_circle(Vector2.ZERO, 14.5, BODY_DARK)   # 外描边
	draw_circle(Vector2.ZERO, 12.5, BODY_COLOR)  # 主体
	draw_set_transform(Vector2.ZERO)

	# 肚皮高光
	draw_circle(Vector2(0, 4), 6.5, BELLY_COLOR)

	# 眼睛
	draw_circle(Vector2(-4.5, -3), 2.6, EYE_COLOR)
	draw_circle(Vector2(4.5, -3), 2.6, EYE_COLOR)
	draw_circle(Vector2(-3.6, -3.9), 0.8, Color(0.92, 1.0, 0.95))
	draw_circle(Vector2(5.4, -3.9), 0.8, Color(0.92, 1.0, 0.95))

	# 头顶嫩芽（随呼吸微微摆动）
	var sprout_top := Vector2(sway, -13.0)
	draw_line(Vector2(0, -9), sprout_top, SPROUT_COLOR, 2.0)
	_draw_leaf(sprout_top, -0.6, -1.0)
	_draw_leaf(sprout_top, 0.6, 1.0)


func _draw_leaf(tip: Vector2, tilt: float, side: float) -> void:
	draw_set_transform(tip, tilt * 0.7 * side, Vector2.ONE)
	draw_circle(Vector2(side * 3.0, -2.0), 3.6, SPROUT_COLOR)
	draw_set_transform(Vector2.ZERO)
