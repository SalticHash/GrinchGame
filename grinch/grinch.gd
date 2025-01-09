extends CharacterBody2D
class_name Player
@onready var INDOORS_SCENE = preload("res://indoors/indoors.tscn")
@onready var WORLD_SCENE = preload("res://world/world.tscn")
var house: int = -1
var exiting_house: bool = false

const MAX_SPEED: float = 300.0
const ACCEL: float = 5.0
const DECEL: float = 5.0
const ACCEL_AIR: float = 5.0
const DECEL_AIR: float = 2.0
var accel: float = ACCEL_AIR
var decel: float = DECEL_AIR
var is_moving: bool = false
var speed: float = 0.0

const DASH_VELOCITY: float = 500.0
const MAX_DASHES: int = 1
var dashes: int = MAX_DASHES

const JUMP_VELOCITY: float = -700.0
const MAX_JUMPS: int = 6
const JUMP_STRENGHT_REGULATOR: float = 8.0
var jumps: int = MAX_JUMPS

var is_direction_pressed: bool = false
var last_pressed_direction: float = 1.0
var pressed_direction: float = 0.0 :
	set(value):
		pressed_direction = value
		if pressed_direction != 0:
			is_direction_pressed = true
			last_pressed_direction = pressed_direction
		else:
			is_direction_pressed = false

signal facing_direction_changed(old_value, new_value)
var facing_direction: float = 1.0 :
	set(value):
		if value == 0: return
		var new_value: float = sign(value)
		if facing_direction == new_value: return
		facing_direction_changed.emit(facing_direction, new_value)
		facing_direction = new_value

func _ready() -> void:
	global_position = Vector2(55, 215)

signal jumped
func jump():
	if !Input.is_action_just_pressed("jump") or jumps <= 0: return
	velocity.y = JUMP_VELOCITY * (float(jumps) / JUMP_STRENGHT_REGULATOR)
	jumps -= 1
	jumped.emit()

signal dashed
func dash():
	if !Input.is_action_pressed("sprint") or dashes <= 0: return
	dashes -= 1
	velocity.x = last_pressed_direction * DASH_VELOCITY
	dashed.emit()

func walk(delta):
	if is_direction_pressed:
		velocity.x = move_toward(velocity.x, pressed_direction * MAX_SPEED, delta * 60 * accel)
	else:
		velocity.x = move_toward(velocity.x, 0, delta * 60 * decel)

# Use degrees
func angle_distance(angle_a: float, angle_b: float) -> float:
	var dist = angle_a - angle_b
	dist = fmod((dist + 180), 360) - 180
	return dist

func _physics_process(delta: float) -> void:
	facing_direction = velocity.x
	speed = abs(velocity.x)
	is_moving = speed > 45.0
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		accel = ACCEL_AIR
		decel = DECEL_AIR
	if is_on_floor() or is_on_wall():
		accel = ACCEL
		decel = DECEL
		jumps = MAX_JUMPS
		dashes = MAX_DASHES
	
	
	pressed_direction = Input.get_axis("left", "right")
	jump()
	dash()
	walk(delta)
	var slide = get_floor_normal().x
	velocity.x += slide * delta * 300 * ((speed + 1) / 100)
			
	move_and_slide()

signal entered_house
func enter_house(house_id: int):
	house = house_id
	await Transition.change_scene(INDOORS_SCENE)
	velocity.y = 100
	global_position = Vector2(0,0)
	entered_house.emit()

func exit_house():
	await Transition.change_scene(WORLD_SCENE)
	exiting_house = true

signal exited_house
func goto_last_chimney():
	var house_container: Node2D = get_node("/root/World/Houses")
	var house_node: StaticBody2D = house_container.get_node(str(house))
	var chimney = house_node.get_node("Chimney")
	velocity = Vector2.ZERO
	global_position = chimney.global_position
	house = -1
	Settings.houses += 1
	await get_tree().create_timer(0.5).timeout
	velocity.y = JUMP_VELOCITY
	exited_house.emit()
	await get_tree().create_timer(0.5).timeout
	exiting_house = false

signal burned
func burn():
	velocity.y = JUMP_VELOCITY
	burned.emit()

signal fell
func fall():
	$SnowPoof.global_position.x = global_position.x
	$SnowPoof.emitting = true
	velocity = Vector2.ZERO
	process_mode = PROCESS_MODE_DISABLED
	fell.emit()
