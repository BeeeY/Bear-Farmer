extends CanvasLayer

signal start
signal intro
signal nextday

var day = 1
var dialougestarted = false
var dialouge = 0
var dialogue_lines: PackedStringArray = [
	"It's my first fall alone, and it's time to 
	prep for winter.",
	"I have 30 days to farm enough food to 
	keep me full while I hibernate.",
	"It's time to set out some roots!",
]

## end-of-game outcomes, checked from the highest food score down to the lowest
const ENDINGS := [
	{"min": 26, "rank": "Legendary", "text": "A feast fit for a long winter nap!"},
	{"min": 16, "rank": "Great", "text": "Well stocked - a cozy hibernation."},
	{"min": 9, "rank": "Good", "text": "A solid harvest, you'll be fine."},
	{"min": 4, "rank": "Survivor", "text": "A meager haul, but you'll scrape by."},
	{"min": 1, "rank": "Hungry", "text": "Barely anything - a cold winter."},
	{"min": 0, "rank": "Starving", "text": "Nothing stored - a grim winter."},
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DayCounter.hide()
	$DialougeBox.hide()
	$Dialouge.hide()
	$PlantsHarvested.hide()
	$SeedCount.hide()
	_hide_end_ui()
	$TitleBackground.play()
	_hide_sign_ui()
	fade_out()
	nextday.connect(FarmManager._on_day_passed)
	FarmManager.inventory_changed.connect(_refresh_inventory)
	_refresh_inventory()

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
	$PlantsHarvested.show()
	$SeedCount.show()
	FarmManager.reset_game()
	_refresh_inventory()
	intro.emit()
	$DialougeBox.show()
	dialouge = 0
	$Dialouge.text = dialogue_lines[0]
	$Dialouge.show()
	dialougestarted = true

	
## hides the shared sign panel and every piece of its UI
func _hide_sign_ui() -> void:
	$NextDayAndShopSign.hide()
	$NextDaySignText.hide()
	$NextDayYes.hide()
	$NextDayNo.hide()
	$ShopLabel.hide()
	$Amount.hide()
	$Value.hide()
	$Money.hide()
	$PlantSelect.hide()
	$BuySellSelect.hide()
	$BuySellButton.hide()
	$ShopExitButton.hide()

## shows the "go to next day?" prompt when the player is by the house
func _on_main_next_day() -> void:
	_hide_sign_ui()
	$NextDayAndShopSign.show()
	$NextDaySignText.show()
	$NextDayYes.show()
	$NextDayNo.show()

## buttons for next day sign
func _on_next_day_yes_pressed() -> void:
	_hide_sign_ui()
	await fade_in()
	await fade_out()
	if day >= 30:
		_show_ending()
		return
	update_daycounter()
	nextday.emit()

## hides the end-of-game results popup
func _hide_end_ui() -> void:
	$EndSign.hide()
	$EndTitle.hide()
	$EndResult.hide()
	$EndButton.hide()

## shows the results popup once all 30 days are done, giving a different outcome
## (rank + message) depending on the weighted amount of food stored
func _show_ending() -> void:
	_hide_sign_ui()
	var food: int = FarmManager.food_total()
	var rank: String = "Starving"
	var text: String = "Nothing stored - a grim winter."
	for tier in ENDINGS:
		if food >= int(tier["min"]):
			rank = str(tier["rank"])
			text = str(tier["text"])
			break
	$EndResult.text = "%s  -  Food: %d\n%s" % [rank, food, text]
	$EndSign.show()
	$EndTitle.show()
	$EndResult.show()
	$EndButton.show()

func _on_end_button_pressed() -> void:
	get_tree().reload_current_scene()
func _on_next_day_no_pressed() -> void:
	_hide_sign_ui()

func update_daycounter():
	day += 1
	$DayCounter.text = "Day : " + str(day)

func fade_in():
	$DayNightFade.show()
	var tween = create_tween()
	tween.tween_property($DayNightFade, "color:a", 1, 1)
	await tween.finished
func fade_out():
	var tween = create_tween()
	tween.tween_property($DayNightFade, "color:a", 0, 1)
	await tween.finished
	$DayNightFade.hide()
	
## opens/closes the shop panel when the player is by the mailbox
func _on_main_shop() -> void:
	if $ShopLabel.visible:
		_hide_sign_ui()
		return
	_hide_sign_ui()
	$NextDayAndShopSign.show()
	$ShopLabel.show()
	$Amount.show()
	$Value.show()
	$Money.show()
	$PlantSelect.show()
	$BuySellSelect.show()
	$BuySellButton.show()
	$ShopExitButton.show()
	_refresh_inventory()

## closes the shop without triggering another interaction
func _on_shop_exit_button_pressed() -> void:
	_hide_sign_ui()

## maps the PlantSelect option index to a crop id
func _selected_crop_id() -> String:
	var idx: int = $PlantSelect.selected
	if idx < 0:
		idx = 0
	return ["1", "2", "3"][idx]

## buys or sells one unit of the selected crop
func _on_buy_sell_button_pressed() -> void:
	var crop_id: String = _selected_crop_id()
	var mode: int = $BuySellSelect.selected
	if mode < 0:
		mode = 0
	var price: int
	var ok: bool
	if mode == 0:
		price = int(FarmManager.SEED_PRICES.get(crop_id, 0))
		ok = FarmManager.buy_seed(crop_id)
	else:
		price = int(FarmManager.CROP_VALUES.get(crop_id, 0))
		ok = FarmManager.sell_crop(crop_id)
	$Amount.text = "Amount : 1"
	$Value.text = "Value : " + str(price)
	$BuySellButton.text = "Done!" if ok else "Can't!"
	await get_tree().create_timer(0.6).timeout
	$BuySellButton.text = "Buy/Sell"

## refreshes the coins and harvested-crop labels from FarmManager
func _refresh_inventory() -> void:
	$Money.text = "Coins : " + str(FarmManager.coins)
	$PlantsHarvested.text = "Carrots: %d\nCorn: %d\nPumpkins: %d" % [
		FarmManager.harvest_count("1"),
		FarmManager.harvest_count("2"),
		FarmManager.harvest_count("3"),
	]
	$SeedCount.text = "Seeds:\nCarrot: %d\nCorn: %d\nPumpkin: %d" % [
		FarmManager.seed_count("1"),
		FarmManager.seed_count("2"),
		FarmManager.seed_count("3"),
	]
