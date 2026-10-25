extends Control
## 可复用的选项面板：全屏开关 + 主音量/音乐/音效。
## 主菜单与暂停菜单共用；点「返回」发出 back_pressed 信号。

signal back_pressed

const UiTheme = preload("res://scripts/ui_theme.gd")

var _wrap: CenterContainer
var _fullscreen_check: CheckButton
var _sliders: Dictionary = {}


func _ready() -> void:
	_wrap = CenterContainer.new()
	_wrap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_wrap.visible = false
	_wrap.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_wrap)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiTheme.panel_style())
	_wrap.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(UiTheme.label("选项", 28, UiTheme.TEXT_BRIGHT))

	_fullscreen_check = CheckButton.new()
	_fullscreen_check.text = "全屏"
	_fullscreen_check.toggled.connect(SaveManager.set_option_fullscreen)
	box.add_child(_fullscreen_check)

	for bus in ["Master", "Music", "SFX"]:
		var bus_name: String = bus
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var name_label := UiTheme.label(_bus_display_name(bus), 16, UiTheme.TEXT)
		name_label.custom_minimum_size = Vector2(64, 0)
		row.add_child(name_label)
		var slider := HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01
		slider.custom_minimum_size = Vector2(180, 0)
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.value_changed.connect(_on_volume.bind(bus_name))
		row.add_child(slider)
		var value_label := UiTheme.label("100%", 14, UiTheme.TEXT)
		value_label.custom_minimum_size = Vector2(44, 0)
		row.add_child(value_label)
		_sliders[bus] = {"slider": slider, "label": value_label}
		box.add_child(row)

	box.add_child(UiTheme.button("返回", _on_back, Vector2(320, 40)))


func show_panel() -> void:
	# 打开时同步当前设置
	_fullscreen_check.set_pressed_no_signal(SaveManager.get_option_fullscreen())
	for bus in _sliders:
		var v := SaveManager.get_option_volume(bus)
		_sliders[bus].slider.set_value_no_signal(v)
		_sliders[bus].label.text = "%d%%" % roundi(v * 100)
	_wrap.visible = true


func hide_panel() -> void:
	_wrap.visible = false


func is_open() -> bool:
	return _wrap.visible


func _bus_display_name(bus: String) -> String:
	return {"Master": "主音量", "Music": "音乐", "SFX": "音效"}[bus]


func _on_volume(v: float, bus: String) -> void:
	SaveManager.set_option_volume(bus, v)
	_sliders[bus].label.text = "%d%%" % roundi(v * 100)


func _on_back() -> void:
	hide_panel()
	back_pressed.emit()
