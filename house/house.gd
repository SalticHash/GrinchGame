extends StaticBody2D

@onready var house_number: int = 0 :
	set(value):
		house_number = value
		$Number.text = str(house_number).pad_zeros(3)
@export var house_id: int = 0 :
	set(value):
		house_id = value
		name = str(house_id)
@export var width: int = 0
@export var size: float = 1.0 :
	set(value):
		size = value
		width *= int(size)
		scale = Vector2.ONE * size

var smoke: bool = false :
	set(value):
		if smoke == value: return
		smoke = value
		$Chimney/Smoke.emitting = smoke
		if smoke:
			$SmokeTimers/TurnOff.start()
			$SmokeTimers/TurnOn.stop()
		else:
			$SmokeTimers/TurnOn.start()
			$SmokeTimers/TurnOff.stop()
			

func _ready() -> void:
	seed(house_id)
	size = randf_range(0.8, 1.2)
	for timer in $SmokeTimers.get_children():
		timer.wait_time = randf_range(1.0, 2.5)
	$SmokeTimers/TurnOn.start()

func entered_chimney(_body: PhysicsBody2D) -> void:
	if Grinch.exiting_house: return
	if smoke:
		Grinch.burn()
		return
	for timer in $SmokeTimers.get_children():
		timer.stop()
	Grinch.enter_house(house_id)

func smoke_toggle() -> void:
	smoke = !smoke
