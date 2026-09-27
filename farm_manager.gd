extends Node

## emitted whenever a tool is actually used on a plot (for player animation)
signal tool_used(tool: Tool)

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
		tool_used.emit(equipped_tool)

func deposit_harvest(result: Dictionary):
	if result.is_empty():
		return
	print("Harvested: ", result.item, " x", result.amount)
	# replace with your actual Inventory autoload call
	
## unequips items
func unequip_everthing() -> void:
	wateringcan_equiped = false
	carrot_equiped = false
	corn_equiped = false
	pumpkin_equiped = false
