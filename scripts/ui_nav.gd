extends RefCounted
## 共用菜单导航：WASD 与方向键移动焦点、Home/End 跳到首/尾控件、
## PgUp/PgDn 滑条大步调值（±10%，无滑条时跳首/尾）、鼠标滚轮调滑条。
## 用法：在界面脚本的 _input 里调用 UiNav.handle(event, self)。


static func handle(event: InputEvent, root: Node) -> bool:
	if event is InputEventMouseButton and event.pressed:
		return _handle_mouse_wheel(event, root)
	if event is InputEventKey and event.pressed and not event.echo:
		return _handle_key(event, root)
	return false


static func _handle_key(event: InputEventKey, root: Node) -> bool:
	match event.physical_keycode:
		KEY_W, KEY_UP:
			return _move_focus(root, Vector2(0, -1))
		KEY_S, KEY_DOWN:
			return _move_focus(root, Vector2(0, 1))
		KEY_A, KEY_LEFT:
			return _move_focus(root, Vector2(-1, 0))
		KEY_D, KEY_RIGHT:
			return _move_focus(root, Vector2(1, 0))
		KEY_HOME:
			return _focus_first(root)
		KEY_END:
			return _focus_last(root)
		KEY_PAGEUP, KEY_PAGEDOWN:
			return _page(root, event.physical_keycode)
	return false


static func _page(root: Node, key: Key) -> bool:
	# 聚焦滑条时大步调值，否则跳到首/尾控件
	var focus := root.get_viewport().gui_get_focus_owner()
	if focus is Range and focus.is_visible_in_tree():
		var r := focus as Range
		var step := (r.max_value - r.min_value) * 0.1
		r.value = clampf(r.value + (step if key == KEY_PAGEUP else -step), r.min_value, r.max_value)
		return true
	return _focus_first(root) if key == KEY_PAGEUP else _focus_last(root)


static func _move_focus(root: Node, dir: Vector2) -> bool:
	var focus := root.get_viewport().gui_get_focus_owner()
	var candidates := _collect(root)
	if candidates.is_empty():
		return false
	if focus == null or not focus.is_visible_in_tree():
		candidates[0].grab_focus()
		return true
	var from := candidates.find(focus)
	var fpos: Vector2 = focus.get_global_rect().get_center()
	var best := -1
	var best_score := INF
	for i in candidates.size():
		if i == from:
			continue
		var cpos: Vector2 = candidates[i].get_global_rect().get_center()
		var delta := cpos - fpos
		var along := delta.dot(dir)
		if along <= 0.0:
			continue
		# 与方向垂直的偏移加大惩罚，优先选正对方向的控件
		var lateral := absf(delta.x * dir.y + delta.y * dir.x)
		var score := along + lateral * 2.5
		if score < best_score:
			best_score = score
			best = i
	if best != -1:
		candidates[best].grab_focus()
	return true


static func _focus_first(root: Node) -> bool:
	var candidates := _collect(root)
	if candidates.is_empty():
		return false
	candidates[0].grab_focus()
	return true


static func _focus_last(root: Node) -> bool:
	var candidates := _collect(root)
	if candidates.is_empty():
		return false
	candidates[-1].grab_focus()
	return true


static func _handle_mouse_wheel(event: InputEventMouseButton, root: Node) -> bool:
	if event.button_index != MOUSE_BUTTON_WHEEL_UP and event.button_index != MOUSE_BUTTON_WHEEL_DOWN:
		return false
	# 鼠标下的滑条：滚轮调值
	for c in _collect(root):
		if c is Range and c.get_global_rect().has_point(event.position):
			var r := c as Range
			var step := r.step * 3.0 * (1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0)
			r.value = clampf(r.value + step, r.min_value, r.max_value)
			return true
	return false


static func _collect(root: Node) -> Array[Control]:
	var out: Array[Control] = []
	_walk(root, out)
	return out


static func _walk(node: Node, out: Array[Control]) -> void:
	if node is CanvasLayer and not node.visible:
		return  # 隐藏的 CanvasLayer（如未打开的暂停菜单）整体跳过
	if node is Control:
		var c := node as Control
		if not c.is_visible_in_tree():
			return
		if c is BaseButton and c.disabled:
			return
		if c.focus_mode != Control.FOCUS_NONE:
			out.append(c)
	for child in node.get_children():
		_walk(child, out)
