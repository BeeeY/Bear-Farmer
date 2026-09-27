extends Node

var plots: Array[FarmPlot] = []       
var crop_database: Dictionary = {}  # id -> CropData
var selected_seed: CropData = null  # set by your seed-picker UI
var equipped_tool: Tool = Tool.Hand

enum Tool { Hand, Carrot_Seeds, Corn_Seeds, Pumpkin_Seeds, Watering_Can }

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
