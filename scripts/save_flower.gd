extends Area2D
## 存档点：玩家碰到发光花时自动保存并显示提示。

const BLOSSOM := Color("#d8ffb0")
const PETAL := Color("#9fffd0")
const STEM := Color("#4fde8e")
const GLOW := Color(0.75, 1.0, 0.55)

var _pulse := 0.0
var _cooldown := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_pulse += delta
	_cooldown = maxf(_cooldown - delta, 0.0)
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and _cooldown <= 0.0:
		_cooldown = 1.0
		SaveManager.save_game()
		var hud := get_tree().get_first_node_in_group("hud")
		if hud != null:
			hud.show_toast("已保存")


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_pulse * 2.0)
	# 光晕（呼吸）
	for i in 4:
		var t := 1.0 - float(i) / 4.0
		draw_circle(Vector2.ZERO, lerpf(6.0, 22.0, t) + pulse * 3.0,
			Color(GLOW, 0.05 + 0.05 * t + 0.06 * pulse))
	# 花茎与花
	draw_line(Vector2(0, 10), Vector2(0, -2), STEM, 2.0)
	draw_circle(Vector2(0, -4), 3.0, BLOSSOM)
	for k in 5:
		var ang := TAU * k / 5.0 + _pulse * 0.3
		draw_circle(Vector2(0, -4) + Vector2.from_angle(ang) * 5.0, 2.0, PETAL)
