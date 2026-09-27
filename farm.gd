extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is FarmPlot:
			FarmManager.plots.append(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
