extends GridContainer


const EnergyScene := preload("res://scenes/ui/energy.tscn")


func _ready() -> void:
	PlayerService.energy.as_signal().subscribe(func(value: int):
		var children := get_children()
		if value < children.size():
			var remaining := children.slice(0, children.size() - value)
			for child in remaining:
				child.queue_free()
		else:
			for i in value - children.size():
				add_child(EnergyScene.instantiate())
	).dispose_with(self)
