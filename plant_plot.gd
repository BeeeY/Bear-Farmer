extends Node2D

var plant = 0
var plant_stage = 0
var watered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_hud_nextday() -> void:
	if watered == true:
		plant_stage += 1
		watered = false
