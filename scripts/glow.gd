extends Node2D
## 柔和光晕。放在角色身上时需配合 CanvasItemMaterial 的 Add 混合模式。

const COLOR := Color(0.55, 1.0, 0.45)
const RINGS := 5


func _draw() -> void:
	for i in RINGS:
		var t := float(i) / (RINGS - 1)
		draw_circle(Vector2.ZERO, lerpf(14.0, 26.0, t), Color(COLOR, 0.10 - 0.06 * t))
