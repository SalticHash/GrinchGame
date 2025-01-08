extends ResourcePreloader
@export var player: Player
@export var sprite: AnimatedSprite2D

func play(sound: String, from_position: float = 0.0) -> AudioStreamPlayer:
	var player_node: AudioStreamPlayer = get_node(sound)
	player_node.play(from_position)
	return player_node

func play_create(sound: String, from_position: float = 0.0) -> AudioStreamPlayer:
	var player_node: AudioStreamPlayer = AudioStreamPlayer.new()
	player_node.stream = get_resource(sound)
	player_node.finished.connect(func(): player_node.queue_free())
	add_child(player_node)
	player_node.play(from_position)
	return player_node

func stop(sound: String):
	var player_node: AudioStreamPlayer = get_node(sound)
	player_node.stop()

func pause(sound: String, paused: bool = true):
	var player_node: AudioStreamPlayer = get_node(sound)
	player_node.stream_paused = paused

func set_volume(sound: String, volume: float):
	var player_node: AudioStreamPlayer = get_node(sound)
	player_node.volume_db = volume

func set_pitch(sound: String, pitch: float):
	var player_node: AudioStreamPlayer = get_node(sound)
	player_node.pitch_scale = pitch

func is_playing(sound: String) -> bool:
	var player_node: AudioStreamPlayer = get_node(sound)
	return player_node.playing

func _ready() -> void:
	sprite.random_idle_played.connect(random_idle_sound)

var idle_sounds: Array[AudioStreamPlayer] = []
func random_idle_sound(id: String) -> void:
	if id == "0":
		idle_sounds.append(play("blink"))
	elif id == "1":
		pass
var stepSound: AudioStreamPlayer = null
var runSound: AudioStreamPlayer = null
var last_on_floor: bool = false
func _process(_delta: float) -> void:
	if last_on_floor != player.is_on_floor() and player.is_on_floor():
		play("land")
	last_on_floor = player.is_on_floor()
	if player.is_moving and player.is_on_floor():
		if player.speed <= player.MAX_SPEED and !is_playing("footstep"):
			stop("blink")
			stop("mouth")
			var pitch = remap(player.speed, 0, player.MAX_SPEED, 0.75, 1.25)
			stepSound = play("footstep")
			stepSound.pitch_scale = pitch
		elif player.speed > player.MAX_SPEED and !is_playing("run"):
			stop("blink")
			stop("mouth")
			var pitch = remap(player.speed, 0, player.MAX_SPEED, 0.75, 1.25)
			runSound = play("run")
			runSound.pitch_scale = pitch
