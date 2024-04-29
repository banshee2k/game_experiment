extends Node2D


func _on_player_detect_body_entered(body):
	World.room_entered.emit(self) # Replace with function body.
