extends Node2D

signal start
signal nextday

var day = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NextDayYes.hide()
	$NextDayNo.hide()
	$NextDaySign.hide()
	$TitleBackground.hide()
	$ColoreRect.hide()
	$DayCounter.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## starts the game
func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$DayCounter.show()
	start.emit()
	
## changes the day
func _on_main_next_day() -> void:
	$NextDayYes.show()
	$NextDayNo.show()
	$NextDaySign.show()

## buttons for next day sign
func _on_next_day_yes_pressed() -> void:
	$NextDayYes.hide()
	$NextDayNo.hide()
	$NextDaySign.hide()
	update_daycounter()
	nextday.emit()
func _on_next_day_no_pressed() -> void:
	$NextDayYes.hide()
	$NextDayNo.hide()
	$NextDaySign.hide()

func update_daycounter():
	day += 1
	$DayCounter.text = "Day : " + str(day)
