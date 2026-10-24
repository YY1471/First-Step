extends Node2D
## 漂浮的萤火虫光点。需配合 CanvasItemMaterial 的 Add 混合模式。

const COUNT := 26

var _flies: Array[Dictionary] = []


func _ready() -> void:
	for i in COUNT:
		_flies.append({
			"pos": Vector2(randf_range(0.0, 640.0), randf_range(0.0, 300.0)),
			"phase": randf_range(0.0, TAU),
			"speed": randf_range(0.3, 1.0),
			"radius": randf_range(6.0, 22.0),
		})


func _process(delta: float) -> void:
	for fly in _flies:
		fly.phase += fly.speed * delta
	queue_redraw()


func _draw() -> void:
	for fly in _flies:
		var t: float = fly.phase
		var pos: Vector2 = fly.pos + Vector2(sin(t * 1.7) * fly.radius * 0.5, cos(t * 1.1) * fly.radius)
		var twinkle := 0.5 + 0.5 * sin(t * 2.3)
		draw_circle(pos, 1.6, Color(0.85, 1.0, 0.6, 0.18 + 0.4 * twinkle))
