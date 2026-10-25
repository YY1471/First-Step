extends Control
## 主菜单：开始游戏 / 继续游戏 / 加载游戏 / 选项 / 退出。
## 界面全部用代码构建；选项面板是共用场景（暂停菜单也使用它）。

const UiTheme = preload("res://scripts/ui_theme.gd")
const UiNav = preload("res://scripts/ui_nav.gd")

var _time := 0.0
var _center: CenterContainer
var _title: Label
var _main_box: VBoxContainer
var _continue_button: Button
var _panels: Array[Control] = []      # 子菜单的外层容器（加载/确认）
var _load_panel: PanelContainer
var _slot_buttons: Array[Button] = []
var _options: Control
var _confirm_panel: PanelContainer
var _confirm_label: Label
var _confirm_action := Callable()


func _ready() -> void:
	_center = CenterContainer.new()
	_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_center)

	_main_box = VBoxContainer.new()
	_main_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_main_box.add_theme_constant_override("separation", 7)
	_center.add_child(_main_box)

	_title = UiTheme.label("植物井", 40, UiTheme.ACCENT)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	_title.add_theme_constant_override("shadow_offset_y", 3)
	_main_box.add_child(_title)

	var subtitle := UiTheme.label("P L A N T   W E L L", 13, Color(0.55, 0.72, 0.6))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_main_box.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	_main_box.add_child(spacer)

	var start_button := UiTheme.button("开始游戏", _on_start, Vector2(230, 34))
	_main_box.add_child(start_button)
	_continue_button = UiTheme.button("继续游戏", _on_continue, Vector2(230, 34))
	_main_box.add_child(_continue_button)
	_main_box.add_child(UiTheme.button("加载游戏", _open_load, Vector2(230, 34)))
	_main_box.add_child(UiTheme.button("选项", _open_options, Vector2(230, 34)))
	_main_box.add_child(UiTheme.button("退出", _on_quit, Vector2(230, 34)))

	var footer := UiTheme.label("植物井 · 原型", 11, Color(0.5, 0.62, 0.55, 0.8))
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_main_box.add_child(footer)

	_build_load_panel()
	_build_confirm_panel()

	# 共用选项面板（与暂停菜单共享）
	_options = preload("res://scenes/options_panel.tscn").instantiate()
	add_child(_options)
	_options.back_pressed.connect(_on_options_closed)

	_refresh_continue()
	start_button.grab_focus()

	# 等待布局完成后检查：内容超高时整体缩小，保证任何窗口下完整显示
	await get_tree().process_frame
	_fit_to_viewport()


func _fit_to_viewport() -> void:
	var content := _center.get_child(0) as Control
	if content.size.y > 330.0:
		_center.scale = Vector2.ONE * (330.0 / content.size.y)


func _process(delta: float) -> void:
	_time += delta
	# 标题呼吸光效
	_title.modulate.a = 0.8 + 0.2 * (0.5 + 0.5 * sin(_time * 2.0))


func _input(event: InputEvent) -> void:
	# WASD / 方向键 / Home / End / PgUp / PgDn / 滚轮 导航
	# （放在 _input 里，先于 GUI，滑条才不会吞掉滚轮事件）
	if UiNav.handle(event, self):
		get_viewport().set_input_as_handled()


# ---- 菜单动作 ----

func _on_start() -> void:
	if SaveManager.has_save(1):
		_show_confirm("开始新游戏会覆盖存档 1，确定吗？", func() -> void: SaveManager.new_game(1))
	else:
		SaveManager.new_game(1)


func _on_continue() -> void:
	SaveManager.continue_game()


func _on_quit() -> void:
	get_tree().quit()


func _refresh_continue() -> void:
	_continue_button.disabled = not SaveManager.has_any_save()


# ---- 加载游戏面板 ----

func _build_load_panel() -> void:
	_load_panel = _make_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	_load_panel.add_child(box)
	box.add_child(UiTheme.label("加载游戏", 28, UiTheme.TEXT_BRIGHT))
	_slot_buttons.clear()
	for i in SaveManager.SLOT_COUNT:
		var btn := UiTheme.button("", _on_slot.bind(i + 1), Vector2(360, 40))
		_slot_buttons.append(btn)
		box.add_child(btn)
	box.add_child(UiTheme.button("返回", _hide_panels, Vector2(360, 40)))


func _open_load() -> void:
	_show_panel(_load_panel)
	for i in SaveManager.SLOT_COUNT:
		var info := SaveManager.get_save_info(i + 1)
		if info.is_empty():
			_slot_buttons[i].text = "存档 %d · 空" % (i + 1)
			_slot_buttons[i].disabled = true
		else:
			_slot_buttons[i].text = "存档 %d · %s" % [i + 1, info.timestamp]
			_slot_buttons[i].disabled = false


func _on_slot(slot: int) -> void:
	SaveManager.load_game(slot)


# ---- 选项（共用面板） ----

func _open_options() -> void:
	_main_box.visible = false
	for wrap in _panels:
		wrap.visible = false
	_options.show_panel()


func _on_options_closed() -> void:
	_main_box.visible = true
	_refresh_continue()


# ---- 确认框 ----

func _build_confirm_panel() -> void:
	_confirm_panel = _make_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	_confirm_panel.add_child(box)
	_confirm_label = UiTheme.label("", 16, UiTheme.TEXT)
	box.add_child(_confirm_label)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	row.add_child(UiTheme.button("确认", _on_confirm_yes, Vector2(110, 40)))
	row.add_child(UiTheme.button("取消", _hide_panels, Vector2(110, 40)))


func _show_confirm(text: String, action: Callable) -> void:
	_confirm_label.text = text
	_confirm_action = action
	_show_panel(_confirm_panel)


func _on_confirm_yes() -> void:
	var action := _confirm_action
	_hide_panels()
	_confirm_action = Callable()
	if action.is_valid():
		action.call()


# ---- 面板切换与工厂 ----

func _make_panel() -> PanelContainer:
	var wrap := CenterContainer.new()
	wrap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrap.visible = false
	wrap.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(wrap)
	_panels.append(wrap)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiTheme.panel_style())
	wrap.add_child(panel)
	return panel


func _show_panel(panel: PanelContainer) -> void:
	_main_box.visible = false
	_options.hide_panel()
	for wrap in _panels:
		wrap.visible = wrap.get_child(0) == panel


func _hide_panels() -> void:
	for wrap in _panels:
		wrap.visible = false
	_main_box.visible = true
	_refresh_continue()
