extends CanvasLayer
## 暂停菜单：继续游戏 / 选项 / 返回主菜单。
## ESC 打开；打开时暂停整棵场景树（本节点始终处理，不受暂停影响）。

const UiTheme = preload("res://scripts/ui_theme.gd")
const UiNav = preload("res://scripts/ui_nav.gd")

var _box: VBoxContainer
var _options: Control
var _resume_button: Button


func _ready() -> void:
	visible = false

	# 半透明遮罩（阻挡点击穿透到游戏）
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiTheme.panel_style())
	center.add_child(panel)

	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 10)
	panel.add_child(_box)

	var title := UiTheme.label("已暂停", 34, UiTheme.ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(title)

	_resume_button = UiTheme.button("继续游戏", _on_resume)
	_box.add_child(_resume_button)
	_box.add_child(UiTheme.button("选项", _open_options))
	_box.add_child(UiTheme.button("返回主菜单", _on_return_menu))

	# 共用选项面板
	_options = preload("res://scenes/options_panel.tscn").instantiate()
	add_child(_options)
	_options.back_pressed.connect(_on_options_closed)


func open() -> void:
	visible = true
	get_tree().paused = true
	_resume_button.grab_focus()


func _on_resume() -> void:
	get_tree().paused = false
	visible = false
	_options.hide_panel()
	_box.visible = true


func _on_return_menu() -> void:
	get_tree().paused = false
	visible = false
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _open_options() -> void:
	_box.visible = false
	_options.show_panel()


func _on_options_closed() -> void:
	_box.visible = true
	_resume_button.grab_focus()


func _input(event: InputEvent) -> void:
	# WASD / 方向键 / Home / End / PgUp / PgDn / 滚轮 导航（先于 GUI 处理）
	if UiNav.handle(event, self):
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or not visible:
		return
	# 选项子面板打开时，ESC 先回到暂停菜单
	if _options.is_open():
		_on_options_closed()
	else:
		_on_resume()
