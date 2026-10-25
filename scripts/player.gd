extends CharacterBody2D
## 玩家角色：左右移动 + 跳跃。
## 手感参考《动物井》：起跳快、落地稳，带土狼时间与跳跃缓冲。

const MAX_SPEED := 200.0          # 最大水平速度
const ACCEL_GROUND := 1800.0      # 地面加速度
const ACCEL_AIR := 1200.0         # 空中加速度
const FRICTION_GROUND := 2200.0   # 地面摩擦力
const FRICTION_AIR := 250.0       # 空中阻力
const GRAVITY := 1500.0           # 重力
const MAX_FALL_SPEED := 560.0     # 最大下落速度
const JUMP_VELOCITY := -580.0     # 起跳速度（越大跳得越高）
const COYOTE_TIME := 0.12         # 土狼时间：离开平台后仍可起跳的宽限（秒）
const JUMP_BUFFER := 0.12         # 跳跃缓冲：落地前按下跳跃会被记住（秒）

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var facing := 1.0                 # 1 = 朝右，-1 = 朝左（供视觉节点读取）


func _physics_process(delta: float) -> void:
	var input_x := Input.get_axis("move_left", "move_right")

	# ---- 垂直：重力与土狼时间 ----
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	# ---- 跳跃缓冲 ----
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER
	jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

	# ---- 水平：加速与摩擦 ----
	var accel := ACCEL_GROUND if is_on_floor() else ACCEL_AIR
	var friction := FRICTION_GROUND if is_on_floor() else FRICTION_AIR
	if input_x != 0.0:
		velocity.x = move_toward(velocity.x, input_x * MAX_SPEED, accel * delta)
		facing = signf(input_x)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# ---- 起跳 ----
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# ---- 可变跳跃高度：上升中松开跳跃键则提前收力 ----
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5

	move_and_slide()
