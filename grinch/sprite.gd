extends AnimatedSprite2D
@export var player: Player

var idle_time: float = 0.0
var idle_expression: float = 1.0

func _ready() -> void:
	player.facing_direction_changed.connect(flip_animation)

func flip_animation(_old_direction: float, new_direction: float) -> void:
	if new_direction == 1:
		$FlipAnimation.play_backwards("flip")
	else:
		$FlipAnimation.play("flip")

signal random_idle_played(id)
func still_animations(delta: float) -> void:
	if !animation.begins_with("random_idle"):
		play("idle")

	if idle_time > idle_expression:
		idle_time = 0.0
		idle_expression = randf_range(1.0, 2.5)
		var random_idle = str(randi_range(0, 1))
		play("random_idle" + random_idle)
		random_idle_played.emit(random_idle)
	
	idle_time += delta

func movement_animations(_delta: float) -> void:
	idle_time = 0
	if player.speed <= player.MAX_SPEED:
		play("walk")
	else:
		play("sprint")

func grounded_animations(delta: float) -> void:
	
	rotation = lerp_angle(rotation, player.get_floor_normal().angle() + PI / 2, delta * 10)

	if player.is_moving or player.is_direction_pressed:
		movement_animations(delta)
	else:
		still_animations(delta)
	speed_scale = remap(player.speed, 0, player.MAX_SPEED, 0.75, 2.0)
	speed_scale = clampf(speed_scale,                      0.75, 2.0)

func airtime_animations(_delta: float) -> void:
	play("jump")
	if $FloorRaycast.is_colliding() and player.velocity.y >= 0:
		print(1)
		var d = player.global_position.distance_to($FloorRaycast.get_collision_point())
		var angle_d = fposmod(rotation_degrees, 360.0)
		var spin = remap(player.velocity.y, 0, 400, 0, 106)
		if angle_d < 10 and d < 50:
			rotation = lerp_angle(rotation, 0.0, 0.5)
		else:
			rotation_degrees += player.velocity.x / 100 * 100 * spin
	else:
		rotation_degrees += player.velocity.x / 100

func _process(delta: float) -> void:
	if player.is_on_floor():
		grounded_animations(delta)
	else:
		airtime_animations(delta)
