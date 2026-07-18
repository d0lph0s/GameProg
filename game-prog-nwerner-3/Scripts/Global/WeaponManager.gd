extends Node

var reload_speed_mod : float = 1.2
var normal_reload_time : float = 3.0
var accuracy_mod : float = 50.0
var normal_damage : float = 25
var damage_mod : float = 1.0
var ammunition_type : int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.ammo_selected.connect(set_ammunition_type)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage() -> float:
	return normal_damage * damage_mod

func accuracy() -> float:
	if accuracy_mod > 100.0:
		accuracy_mod = 100
	return (100.0 - accuracy_mod)

func reload_time() -> float:
	return (1/reload_speed_mod * normal_reload_time)

func set_ammunition_type(ammo_name : StringName) -> void:
	match ammo_name:
		_ when "01" in ammo_name:
			ammunition_type = 0
		_ when "02" in ammo_name && not "12ga" in ammo_name:
			ammunition_type = 1
		_ when "03" in ammo_name && not "12ga" in ammo_name:
			ammunition_type = 2
		_ when "04" in ammo_name && not "12ga" in ammo_name:
			ammunition_type = 3
		_ when "12ga_02" in ammo_name:
			ammunition_type = 4
		_ when "12ga_02" in ammo_name:
			ammunition_type = 5
		_ when "12ga_02" in ammo_name:
			ammunition_type = 6
	pass
