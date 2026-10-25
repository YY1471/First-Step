extends Node2D
## 主场景：ESC 打开暂停菜单（暂停菜单由 PauseMenu 节点提供）。


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		$PauseMenu.open()
		# 消费本次事件，避免暂停菜单在同一次派发中收到 ESC 立即关闭
		get_viewport().set_input_as_handled()
