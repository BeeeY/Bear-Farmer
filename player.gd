extends CharacterBody2D


@export var SPEED = 300

func _physics_process(delta: float) -> void:

## moves player up and down
	var updown := Input.get_axis("w", "s")
	if updown:
		velocity.y = updown * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)
## moves player left and right
	var leftright := Input.get_axis("a", "d")
	if leftright:
		velocity.x = leftright * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

## moves the player somewhere
func spawn(pos):
	position = pos
