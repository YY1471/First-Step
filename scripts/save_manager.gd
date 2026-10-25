extends Node
## 全局存档与选项管理（自动加载单例）。
## 存档文件：user://saves/slot_N.json；选项文件：user://options.cfg。

const SLOT_COUNT := 3
const SAVE_DIR := "user://saves"
const OPTIONS_PATH := "user://options.cfg"

var current_slot := 1
var pending_position := false   # 从存档进入时覆盖玩家出生点的标志
var pending_pos := Vector2.ZERO

var _fullscreen := false
var _volumes: Dictionary = {"Master": 1.0, "Music": 1.0, "SFX": 1.0}


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	_load_options()


# ---- 存档 ----

func slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))


func has_any_save() -> bool:
	for i in SLOT_COUNT:
		if has_save(i + 1):
			return true
	return false


func new_game(slot: int) -> void:
	current_slot = slot
	pending_position = false
	var path := slot_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func continue_game() -> bool:
	# 找时间戳最新的存档
	var best := -1
	var best_time := ""
	for i in SLOT_COUNT:
		var info := get_save_info(i + 1)
		if not info.is_empty() and info.timestamp > best_time:
			best = i + 1
			best_time = info.timestamp
	if best == -1:
		return false
	load_game(best)
	return true


func load_game(slot: int) -> void:
	current_slot = slot
	var data := _read_save(slot)
	pending_position = true
	pending_pos = Vector2(data.position[0], data.position[1])
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func save_game() -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	var pos := player.position if player != null else Vector2(60, 240)
	var data := {
		"version": 1,
		"timestamp": Time.get_datetime_string_from_system(false, true),
		"room": "main",
		"position": [pos.x, pos.y],
	}
	var file := FileAccess.open(slot_path(current_slot), FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func get_save_info(slot: int) -> Dictionary:
	var data := _read_save(slot)
	if data.is_empty():
		return {}
	return {"timestamp": data.timestamp, "position": data.position}


func _read_save(slot: int) -> Dictionary:
	var path := slot_path(slot)
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return data if data is Dictionary else {}


# ---- 选项 ----

func get_option_fullscreen() -> bool:
	return _fullscreen


func get_option_volume(bus: String) -> float:
	return _volumes.get(bus, 1.0)


func set_option_fullscreen(on: bool) -> void:
	_fullscreen = on
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)
	_save_options()


func set_option_volume(bus: String, value: float) -> void:
	_volumes[bus] = value
	var idx := AudioServer.get_bus_index(bus)
	if idx != -1:
		AudioServer.set_bus_mute(idx, value <= 0.001)
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(value, 0.001)))
	_save_options()


func _load_options() -> void:
	var cf := ConfigFile.new()
	if cf.load(OPTIONS_PATH) != OK:
		return
	_fullscreen = cf.get_value("options", "fullscreen", false)
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if _fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	for bus in _volumes:
		var value: float = cf.get_value("options", "volume_%s" % bus, 1.0)
		_volumes[bus] = value
		var idx := AudioServer.get_bus_index(bus)
		if idx != -1:
			AudioServer.set_bus_mute(idx, value <= 0.001)
			AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(value, 0.001)))


func _save_options() -> void:
	var cf := ConfigFile.new()
	cf.set_value("options", "fullscreen", _fullscreen)
	for bus in _volumes:
		cf.set_value("options", "volume_%s" % bus, _volumes[bus])
	cf.save(OPTIONS_PATH)
