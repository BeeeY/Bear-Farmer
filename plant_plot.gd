extends Node2D
class_name FarmPlot

enum State { Empty, Planted, Ready }

@export var plot_id = 0
@onready var sprite = $AnimatedSprite2D


var state: State = State.Empty
var crop = CropData
var plant_stage = 0
var days_grown = 0
var watered = false
var player_nearby = false

func _ready():
	$Water.hide()
	
func _process(delta):
	if player_nearby == false:
		return
	elif player_nearby == true && Input.is_action_just_pressed("e"):
		match FarmManager.equipped_tool:
			FarmManager.Tool.Carrot_Seeds:
				if state == State.Empty:
					FarmManager.request_plant(self)
			FarmManager.Tool.Corn_Seeds:
				if state == State.Empty:
					FarmManager.request_plant(self)
			FarmManager.Tool.Pumpkin_Seeds:
				if state == State.Empty:
					FarmManager.request_plant(self)
			FarmManager.Tool.Watering_Can:
				water()
			FarmManager.Tool.Hand:
				if state == State.Ready:
					var result = harvest()
					FarmManager.deposit_harvest(result)

func plant(new_crop: CropData):
	if state != State.Empty:
		return
	crop = new_crop
	days_grown = 0
	state = State.Planted
	update_sprite()

func _on_hud_nextday() -> void:
	if state != State.Planted:
		return
	if watered:
		days_grown += 1
		if days_grown >= crop.days_to_grow:
			state = State.Ready
	$Water.hide()
	watered = false
	update_sprite()

func update_sprite():
	if crop == null:
		sprite.texture = null
		return
	var stage_count = crop.stage_textures.size()
	var progress = float(days_grown) / float(crop.days_to_grow)
	var index = min(int(progress * stage_count), stage_count - 1)
	sprite.texture = crop.stage_textures[index]
	
func harvest() -> Dictionary:
	if state != State.Ready:
		return {}
	var result = {"item": crop.yield_item, "amount": crop.yield_amount}
	state = State.Empty
	crop = null
	days_grown = 0
	update_sprite()
	return result
	
func water():
	if state == State.Planted and not watered:
		$Water.show()
		watered = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
