extends Camera2D

func _ready():
	World.room_entered.connect(func(room):
		global_position = room.global_position
	)
