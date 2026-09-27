extends Node2D
class_name FarmPlot

enum State { Empty, Planted, Ready }

const DIRT_TEXTURE := preload("res://assets/plant standin1.png")

@export var plot_id: int = 0
@onready var sprite: Sprite2D = $CropSprite

var state: State = State.Empty
var crop: CropData = null
var plant_stage: int = 0
var days_grown: int = 0
var watered: bool = false
var player_nearby: bool = false

func _ready() -> void:
	$Water.hide()
	update_sprite()
	
func _process(_delta: float) -> void:
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

func plant(new_crop: CropData) -> void:
	if state != State.Empty:
		return
	crop = new_crop
	days_grown = 0
	watered = false
	state = State.Planted
	update_sprite()

func advance_day() -> void:
	if state != State.Planted:
		return
	if watered:
		days_grown += 1
		if days_grown >= crop.days_to_grow:
			state = State.Ready
	$Water.hide()
	watered = false
	update_sprite()

func update_sprite() -> void:
	if crop == null:
		sprite.texture = DIRT_TEXTURE
		return
	var stage_count: int = crop.stage_sprites.size()
	if stage_count == 0:
		sprite.texture = DIRT_TEXTURE
		return
	var progress: float = float(days_grown) / float(max(crop.days_to_grow, 1))
	var index: int = clampi(int(progress * stage_count), 0, stage_count - 1)
	sprite.texture = crop.stage_sprites[index]
	
func harvest() -> Dictionary:
	if state != State.Ready:
		return {}
	var result: Dictionary = {"item": crop.name, "amount": crop.yield_amount}
	state = State.Empty
	crop = null
	days_grown = 0
	update_sprite()
	return result
	
func water():
	if state == State.Planted and not watered:
		$Water.show()
		watered = true
		FarmManager.tool_used.emit(FarmManager.Tool.Watering_Can)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
