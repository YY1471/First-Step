extends CanvasLayer
## 游戏内 HUD：操作提示与「已保存」浮字。


func _ready() -> void:
	add_to_group("hud")

	var toast := Label.new()
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.anchors_preset = Control.PRESET_TOP_WIDE
	toast.position.y = 64
	toast.add_theme_font_size_override("font_size", 20)
	toast.add_theme_color_override("font_color", Color("#d8ffb0"))
	toast.modulate.a = 0.0
	add_child(toast)
	_toast = toast

	var hint := Label.new()
	hint.text = "ESC 暂停"
	hint.position = Vector2(10, 342)
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.6, 0.75, 0.65, 0.7))
	add_child(hint)


var _toast: Label


func show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.6)
