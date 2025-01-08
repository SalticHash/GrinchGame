extends CanvasLayer

func set_gifts(gifts: int):
	$Screen/Gifts.text = "Gifts: " + str(gifts).pad_zeros(6) + " / 10000"

func set_houses(houses: int):
	$Screen/Houses.text = "Houses: " + str(houses).pad_zeros(3) + " / 100"
