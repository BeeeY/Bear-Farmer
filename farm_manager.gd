extends Node

## emitted whenever a tool is actually used on a plot (for player animation)
signal tool_used(tool: Tool)
## emitted whenever coins or crop/seed counts change (for the HUD)
signal inventory_changed

## crop id -> price of one seed (corn & pumpkin cost more than carrot)
const SEED_PRICES := {"1": 5, "2": 12, "3": 22}
## crop id -> coins earned by selling one harvested crop (better crops sell for more)
const CROP_VALUES := {"1": 12, "2": 25, "3": 50}
## crop id -> food points one harvested crop is worth at the end of the game
const FOOD_VALUES := {"1": 1, "2": 2, "3": 3}

var plots: Array[FarmPlot] = []       
var crop_database: Dictionary = {}  # id -> CropData
var selected_seed: CropData = null  # set by your seed-picker UI
var equipped_tool: Tool = Tool.Hand
var carrot_seeds = 0
var corn_seeds = 0
var pumpkin_seeds = 0
var wateringcan_equiped = false
var carrot_equiped = false
var corn_equiped = false
var pumpkin_equiped = false
var player_by_house = false
enum Tool { Hand, Carrot_Seeds, Corn_Seeds, Pumpkin_Seeds, Watering_Can }

var coins: int = 50
var seeds: Dictionary = {}       # crop id -> seeds owned
var harvested: Dictionary = {}   # crop id -> harvested crops not yet sold

	## detects for swapping tools with number keys 1-4
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("1"):
		select_tool(Tool.Watering_Can)
	elif Input.is_action_just_pressed("2"):
		select_tool(Tool.Carrot_Seeds)
	elif Input.is_action_just_pressed("3"):
		select_tool(Tool.Corn_Seeds)
	elif Input.is_action_just_pressed("4"):
		select_tool(Tool.Pumpkin_Seeds)

	## selects a tool, or puts it away again if it is already selected
func select_tool(tool: Tool) -> void:
	if equipped_tool == tool:
		clear_tool()
		return
	unequip_everthing()
	equipped_tool = tool
	# a seed tool also chooses which crop gets planted
	selected_seed = _crop_for_tool(tool)
	wateringcan_equiped = tool == Tool.Watering_Can
	carrot_equiped = tool == Tool.Carrot_Seeds
	corn_equiped = tool == Tool.Corn_Seeds
	pumpkin_equiped = tool == Tool.Pumpkin_Seeds

	## puts the current tool away and falls back to the bare hand
func clear_tool() -> void:
	unequip_everthing()
	equipped_tool = Tool.Hand
	selected_seed = null

	## maps a seed tool to the crop resource it plants
func _crop_for_tool(tool: Tool) -> CropData:
	match tool:
		Tool.Carrot_Seeds:
			return crop_database.get("1") as CropData
		Tool.Corn_Seeds:
			return crop_database.get("2") as CropData
		Tool.Pumpkin_Seeds:
			return crop_database.get("3") as CropData
		_:
			return null

func _ready() -> void:
	_load_crop_database()
	equipped_tool = Tool.Hand
	selected_seed = null
	reset_game()

## resets the economy for a fresh run (called when a new game starts)
func reset_game() -> void:
	coins = 50
	seeds = {"1": 3, "2": 0, "3": 0}
	harvested = {"1": 0, "2": 0, "3": 0}
	inventory_changed.emit()

func _load_crop_database():
	var dir = DirAccess.open("res://crops/")
	for file_name in dir.get_files():
		if file_name.ends_with(".tres"):
			var crop: CropData = load("res://crops/" + file_name)
			crop_database[crop.id] = crop

func _on_day_passed():
	for p in plots:
		p.advance_day()

func request_plant(plot: FarmPlot):
	if selected_seed == null:
		return
	if plot.state != FarmPlot.State.Empty:
		return
	var id: String = selected_seed.id
	if seed_count(id) <= 0:
		return
	seeds[id] = seed_count(id) - 1
	plot.plant(selected_seed)
	tool_used.emit(equipped_tool)
	inventory_changed.emit()

func deposit_harvest(result: Dictionary) -> void:
	if result.is_empty():
		return
	var id: String = str(result.get("id", ""))
	harvested[id] = int(harvested.get(id, 0)) + int(result.get("amount", 0))
	print("Harvested: ", result.get("item", "?"), " x", result.get("amount", 0))
	inventory_changed.emit()

## buys one seed of the given crop id; returns true if it was affordable
func buy_seed(crop_id: String) -> bool:
	var price: int = int(SEED_PRICES.get(crop_id, 0))
	if coins < price:
		return false
	coins -= price
	seeds[crop_id] = int(seeds.get(crop_id, 0)) + 1
	inventory_changed.emit()
	return true

## sells one harvested crop of the given crop id; returns true if one was held
func sell_crop(crop_id: String) -> bool:
	if int(harvested.get(crop_id, 0)) <= 0:
		return false
	harvested[crop_id] = int(harvested.get(crop_id, 0)) - 1
	coins += int(CROP_VALUES.get(crop_id, 0))
	inventory_changed.emit()
	return true

func seed_count(crop_id: String) -> int:
	return int(seeds.get(crop_id, 0))

func harvest_count(crop_id: String) -> int:
	return int(harvested.get(crop_id, 0))

## total "food" stored, weighting richer crops higher (used for the end-of-game result)
func food_total() -> int:
	var total: int = 0
	for id in FOOD_VALUES:
		total += harvest_count(id) * int(FOOD_VALUES[id])
	return total

## unequips items
func unequip_everthing() -> void:
	wateringcan_equiped = false
	carrot_equiped = false
	corn_equiped = false
	pumpkin_equiped = false
