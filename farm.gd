extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_collect_plots(self)


# Recursively finds every FarmPlot in the tree (they are nested inside
# Control nodes that make up the grid cells).
func _collect_plots(node: Node) -> void:
	for child in node.get_children():
		if child is FarmPlot:
			FarmManager.plots.append(child)
		_collect_plots(child)
