extends Node2D

signal start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NextDayYes.hide()
	$NextDayNo.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## starts the game
func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start.emit()
	
## changes the day
func _on_main_next_day() -> void:
	pass # Replace with function body.
