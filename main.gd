extends Node2D

signal next_day
signal game_over
signal shop
signal wateringcan
signal carrot
signal corn
signal pumpkin

var score = 0
var day = 0 
var player_by_house = false
var player_by_mailbox = false
var spawn_point
var house_spawn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_point = $Spawn.position
	house_spawn = $Spawn2.position
	$House/HouseSprite.animation = "default"
	$Mailbox/MailboxSprite.animation = "default"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	## on day 30 game ends
	if day == 30:
		game_over.emit()
	
	## changes what the house looks like when the player is nearby
	if player_by_house == true:
		if Input.is_action_just_pressed("e"):
			next_day.emit()
	if player_by_mailbox == true:
		if Input.is_action_just_pressed("e"):
			shop.emit()
			

## puts the player at spawn when the game starts
func _on_hud_start() -> void:
	$Player.set_physics_process(true)
	
func _on_hud_intro() -> void:
	$Player.spawn(spawn_point)
	$Player.set_physics_process(false)
	
func _on_hud_nextday() -> void:
	day += 1
	$Player.spawn(house_spawn)

## detects if the player is by the house
func _on_house_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_by_house = true
		$House/HouseSprite.animation = "player_nearby"
func _on_house_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
			player_by_house = false
			$House/HouseSprite.animation = "default"
			
func _on_mailbox_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_by_mailbox = true
		$Mailbox/MailboxSprite.animation = "player_nearby"
func _on_mailbox_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
			player_by_mailbox = false
			$Mailbox/MailboxSprite.animation = "default"


	
