extends CanvasLayer

signal start
signal nextday

var day = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NextDaySign.hide()
	$TitleBackground.hide()
	$DayCounter.hide()
	toggle_shop()
	fade_out()
	nextday.connect(FarmManager._on_day_passed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## starts the game
func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$Title.hide()
	$TitleBackground.hide()
	$ColorRect.hide()
	$DayCounter.show()
	start.emit()
	
## changes the day
func _on_main_next_day() -> void:
	$NextDaySign.show()

## buttons for next day sign
func _on_next_day_yes_pressed() -> void:
	$NextDaySign.hide()
	await fade_in()
	await fade_out()
	update_daycounter()
	nextday.emit()
func _on_next_day_no_pressed() -> void:
	$NextDaySign.hide()

func update_daycounter():
	day += 1
	$DayCounter.text = "Day : " + str(day)

func fade_in():
	var tween = create_tween()
	tween.tween_property($DayNightFade, "color:a", 1, 1)
	await tween.finished
func fade_out():
	var tween = create_tween()
	tween.tween_property($DayNightFade, "color:a", 0, 1)
	await tween.finished
	
func toggle_shop():
	if $Shop.visible:
		$Shop.hide()
		$BuySell.hide()
		$Amount.hide()
		$Value.hide()
		$Upgrades.hide()
		$Money.hide()
		$PlantSelect.hide()
		$BuySellSelect.hide()
	else:
		$Shop.show()
		$BuySell.show()
		$Amount.show()
		$Value.show()
		$Upgrades.show()
		$Money.show()
		$PlantSelect.show()
		$BuySellSelect.show()
