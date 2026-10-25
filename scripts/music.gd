extends Node
## 背景音乐播放器（自动加载单例）：菜单与游戏中持续循环播放。
## 音量受「选项 → 音乐」滑条控制（Music 总线）。

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Music"
	_player.volume_db = -8.0  # 背景音乐放轻一点
	add_child(_player)
	# 运行时显式设置完整循环区间（采样数）。
	# 注意：只设 loop_mode 不设 loop_end 会得到空循环区间、播放立即结束；
	# 且导入后的流是 QOA 压缩格式，不能拿 data.size() 算样本数。
	var stream := load("res://assets/music.wav") as AudioStreamWAV
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = int(stream.get_length() * stream.mix_rate)
	_player.stream = stream
	_player.play()
