extends CanvasLayer

signal start
signal intro
signal nextday

var day = 1
var dialougestarted = false
var dialouge = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NextDaySign.hide()
	$DayCounter.hide()
	$DialougeBox.hide()
	$TitleBackground.play()
	toggle_shop()
	fade_out()
	nextday.connect(FarmManager._on_day_passed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		if dialougestarted == true && dialouge == 1:
			$Dialouge.text = "It's my first fall alone, and it's time to 
			prep for winter."
			$Dialouge.show()
			dialouge += 1
		if Input.is_action_just_pressed("e") && dialouge == 2:
			$Dialouge.text = "I have 30 days to farm enough food to 
			keep me full while I hibernate."
			dialouge +=1
		if Input.is_action_just_pressed("e") && dialouge == 3:
			$Dialouge.text = "It's time to set out some roots!"
			dialouge +=1
		if Input.is_action_just_pressed("e") && dialouge == 4:
			$Dialouge.hide()
			$DialougeBox.hide()
			start.emit()

## starts the game
func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$Title.hide()
	$TitleBackground.hide()
	$DayCounter.show()
	intro.emit()
	$DialougeBox.show()
	dialougestarted = true

	
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
