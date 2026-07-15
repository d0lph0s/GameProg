extends Node

var reload_speed : float = 1.2
var normal_reload_time : float = 3.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reload_time() -> float:
	return (1/reload_speed * normal_reload_time)
