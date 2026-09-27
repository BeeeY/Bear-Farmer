extends Node

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

	## detects for swapping tools
func _process(delta: float):
	if Input.is_action_just_pressed("1"):
		if wateringcan_equiped == true:
			unequip_everthing()
		else:
			unequip_everthing()
			wateringcan_equiped = true
			equipped_tool = Tool.Watering_Can
	if Input.is_action_just_pressed("2"):
		if carrot_equiped == true:
			unequip_everthing()
		else:
			unequip_everthing()
			carrot_equiped = true
			equipped_tool = Tool.Carrot_Seeds
	if Input.is_action_just_pressed("3"):
		if corn_equiped == true:
			unequip_everthing()
		else:
			unequip_everthing()
			corn_equiped = true
			equipped_tool = Tool.Corn_Seeds
	if Input.is_action_just_pressed("4"):
		if pumpkin_equiped:
			unequip_everthing()
		else:
			unequip_everthing()
			pumpkin_equiped = true
			equipped_tool = Tool.Pumpkin_Seeds

func _ready():
	_load_crop_database()
	equipped_tool = Tool.Watering_Can

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
	if selected_seed:
		plot.plant(selected_seed)

func deposit_harvest(result: Dictionary):
	if result.is_empty():
		return
	print("Harvested: ", result.item, " x", result.amount)
	# replace with your actual Inventory autoload call
	
## unequips items
func unequip_everthing():
	wateringcan_equiped = false
	carrot_equiped = false
	corn_equiped = false
	pumpkin_equiped = false
	player_by_house = false
