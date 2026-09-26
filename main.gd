extends Node2D

signal next_day
signal game_over

var score = 0
var day = 0 
var carrot_seeds = 0
var corn_seeds = 0
var pumpkin_seeds = 0
var wateringcan_equiped = false
var carrot_equiped = false
var corn_equiped = false
var pumpkin_equiped = false
var player_by_house = false
var spawn_point

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_point = $Spawn.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	## on day 30 game ends
	if day == 30:
		game_over.emit()
	
	## changes what the house looks like when the player is nearby
	if player_by_house == true:
		$House/HouseSprite.animation = "player_nearby"
		if Input.is_action_just_pressed("e"):
			next_day.emit()
	elif player_by_house == false:
		$House/HouseSprite.animation = "default"
		
	## detects for swapping tools
	if Input.is_action_just_pressed("1"):
		if wateringcan_equiped == true:
			unequip_everthing()
		else:
			unequip_everthing()
			wateringcan_equiped = true
	if Input.is_action_just_pressed("2"):
		if carrot_equiped == true:
			unequip_everthing()
		else:
			unequip_everthing()
			carrot_equiped = true
	if Input.is_action_just_pressed("3"):
		if corn_equiped == true:
			unequip_everthing()
		else:
			unequip_everthing()
			corn_equiped = true
	if Input.is_action_just_pressed("4"):
		if pumpkin_equiped:
			unequip_everthing()
		else:
			unequip_everthing()
			pumpkin_equiped = true
			

## puts the player at spawn when the game starts
func _on_hud_start() -> void:
	$Player.spawn(spawn_point)
	
func _on_hud_nextday() -> void:
	day += 1

## detects if the player is by the house
func _on_house_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_by_house = true
func _on_house_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
			player_by_house = false

## unequips items
func unequip_everthing():
	wateringcan_equiped = false
	carrot_equiped = false
	corn_equiped = false
	pumpkin_equiped = false
	player_by_house = false
	
