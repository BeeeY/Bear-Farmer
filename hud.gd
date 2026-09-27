extends CanvasLayer

signal start
signal intro
signal nextday

var day = 1
var dialougestarted = false
var dialouge = 0
var dialogue_lines: PackedStringArray = [
	"It's my first fall alone, and it's time to prep for winter.",
	"I have 30 days to farm enough food to keep me full while I hibernate.",
	"It's time to set out some roots!",
]

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
func _process(_delta: float) -> void:
	if dialougestarted:
		if Input.is_action_just_pressed("click"):
			advance_dialogue()

## shows the next intro line, or closes the intro after the last one
func advance_dialogue() -> void:
	dialouge += 1
	if dialouge >= dialogue_lines.size():
		dialougestarted = false
		$Dialouge.hide()
		$DialougeBox.hide()
		start.emit()
		return
	$Dialouge.text = dialogue_lines[dialouge]
	$Dialouge.show()

## starts the game
func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$Title.hide()
	$TitleBackground.hide()
	$DayCounter.show()
	intro.emit()
	$DialougeBox.show()
	dialouge = 0
	$Dialouge.text = dialogue_lines[0]
	$Dialouge.show()
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


func _on_main_shop() -> void:
	$Shop.show()
	$BuySell.show()
	$BuySellSelect.show()
	$Amount.show()
	$Money.show()
	$Value.show()
	$PlantSelect.show()
