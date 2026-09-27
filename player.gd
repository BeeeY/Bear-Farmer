extends CharacterBody2D


@export var SPEED: int = 300

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

## last direction the player faced, used for the idle pose
var facing: String = "down"
## true while a one-shot farming animation is playing
var action_playing: bool = false


func _ready() -> void:
	FarmManager.tool_used.connect(_on_tool_used)
	sprite.animation_finished.connect(_on_action_finished)


func _physics_process(_delta: float) -> void:
	## move the player and play the animation that matches the direction
	var input_dir: Vector2 = Input.get_vector("a", "d", "w", "s")
	velocity = input_dir * SPEED

	if not action_playing:
		_update_walk_animation(input_dir)

	move_and_slide()


## picks the walk animation (or idle pose) for the way the player is moving
func _update_walk_animation(input_dir: Vector2) -> void:
	if input_dir == Vector2.ZERO:
		sprite.animation = facing
		sprite.frame = 0
		sprite.stop()
		return
	facing = _facing_from_direction(input_dir)
	sprite.animation = facing
	sprite.play()


## maps a movement direction to one of the four walk animation names
func _facing_from_direction(dir: Vector2) -> String:
	if absf(dir.x) >= absf(dir.y):
		return "right" if dir.x > 0 else "left"
	return "down" if dir.y > 0 else "up"


## plays the matching action animation when a tool is used on a plot
func _on_tool_used(tool: int) -> void:
	match tool:
		FarmManager.Tool.Carrot_Seeds, FarmManager.Tool.Corn_Seeds, FarmManager.Tool.Pumpkin_Seeds:
			_play_action("planting")
		FarmManager.Tool.Watering_Can:
			_play_action("watering")


## plays a one-shot action animation, then returns to the walk/idle pose
func _play_action(anim_name: String) -> void:
	action_playing = true
	sprite.sprite_frames.set_animation_loop(anim_name, false)
	sprite.animation = anim_name
	sprite.play()


func _on_action_finished() -> void:
	if not action_playing:
		return
	action_playing = false
	sprite.animation = facing
	sprite.frame = 0
	sprite.stop()


## moves the player somewhere
func spawn(pos: Vector2) -> void:
	position = pos
