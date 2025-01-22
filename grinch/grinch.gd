extends CharacterBody2D
class_name Player
@onready var INDOORS_SCENE = preload("res://indoors/indoors.tscn")
@onready var WORLD_SCENE = preload("res://world/world.tscn")
var current_house_id: String = "NONE"
var entering_house: bool = false
var exiting_house: bool = false

const SLIDE_FORCE: float = 300.0
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
const MAX_DASH_TIME: float = 2.5
var dash_buffer: float = MAX_DASH_TIME

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
func dash(delta: float):
	if !Input.is_action_pressed("sprint") or dash_buffer <= 0: return
	dash_buffer -= delta
	velocity.x = last_pressed_direction * DASH_VELOCITY
	dashed.emit()

func walk(delta):
	if is_direction_pressed:
		velocity.x = move_toward(velocity.x, pressed_direction * MAX_SPEED, delta * 60 * accel)
	else:
		velocity.x = move_toward(velocity.x, 0, delta * 60 * decel)

func slide(delta):
	var slide_force = get_floor_normal().x
	var slip_speed_factor = (speed / 100) + 1.0
	velocity.x += slide_force * slip_speed_factor * delta * SLIDE_FORCE

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
		dash_buffer = MAX_DASH_TIME
	
	
	pressed_direction = Input.get_axis("left", "right")
	jump()
	dash(delta)
	walk(delta)
	slide(delta)
			
	move_and_slide()

## HOUSE ENTERING AND EXITING ##
func enter_house(house_id: String):
	current_house_id = house_id
	await Transition.change_scene(INDOORS_SCENE)
	entering_house = true

signal entered_house
func goto_entered_house():
	var chimney_container: Node2D = get_node("/root/Indoors/TileMapLayer/Chimneys")
	var chimney: Area2D = chimney_container.get_node(str(current_house_id))
	
	velocity = Vector2.ZERO
	global_position = chimney.global_position + Vector2(0, $Collision.shape.height)
	
	entered_house.emit()
	entering_house = false

func exit_house():
	await Transition.change_scene(WORLD_SCENE)
	exiting_house = true

signal exited_house
func goto_exited_house():
	var chimney_container: Node2D = get_node("/root/World/TileMapLayer/Chimneys")
	var chimney: Area2D = chimney_container.get_node(str(current_house_id))
	
	velocity = Vector2.ZERO
	global_position = chimney.global_position
	
	current_house_id = "NONE"
	
	Settings.houses += 1
	await get_tree().create_timer(0.5).timeout
	velocity.y = JUMP_VELOCITY
	exited_house.emit()
	await get_tree().create_timer(0.5).timeout
	exiting_house = false

## HOUSE ENTERING AND EXITING ##


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
