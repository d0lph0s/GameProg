extends Node

#for loading after modification
var weapon_scene : PackedScene
var weapon_components : Dictionary = {"Platform" : null, "Magazine" : null, "Ammunition" : null, "PumpHandle" : null, "Barrel" : null, "Trigger" : null, "Slide" : null, "Sight" : null, "Muzzle" : null}

#Exportready Stats
var fin_damage : int = 0
var fin_damage_flat : int = 0
var fin_damage_mult : float = 0
var fin_reload_time : float = 1.0
var fin_reload_time_flat : float = 1.0
var fin_reload_mult : float = 1.0
var fin_accuracy : float = 0.0
var fin_accuracy_flat : float = 0.0
var fin_accuracy_mult : float = 1.0
var fin_magazine_size : int = 1

#Stats

#weapon
var weapon_reload_time : float = 3.0
var weapon_accuracy : float
var weapon_damage : float = 10.0

#extras
var sight_accuracy : float = 1.0
var muzzle_damage_mult : float = 1.0
var muzzle_accuracy_mult : float = 1.0
var barrel_damage_mult : float = 1.0
var barrel_accuracy_mult : float = 1.0
var slide_reload_mult : float = 1.0

#ammunition
var magazine_reload_mult : float = 1.0
var magazine_size : int = 1
var ammunition_type : int = -1

#for calculation of other stuff (HALLO MANU/ALEX) (Ja ich habe diesen Lösungsansatz tatsächlich selber gewählt XD)
var barrel_mesh : Mesh
var barrel_socket : Vector3

func export_parameters() -> void:
	fin_reload_time = reload_time()
	fin_accuracy = accuracy()
	fin_damage = damage()
	c_fin_magazine_size_comp()
	SignalManager.stats_updated.emit()

func c_fin_magazine_size_comp() -> void:
	fin_magazine_size = magazine_size

func c_fin_reload_comp() -> void:
	fin_reload_mult = magazine_reload_mult * slide_reload_mult
	fin_reload_time_flat = weapon_reload_time

func c_fin_accuracy_comp() -> void:
	fin_accuracy_mult = muzzle_accuracy_mult * barrel_accuracy_mult
	fin_accuracy_flat = weapon_accuracy + sight_accuracy

func c_fin_damage_comp() -> void:
	fin_damage_flat = weapon_damage
	fin_damage_mult = barrel_damage_mult * muzzle_damage_mult
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weapon_scene = PackedScene.new()
	weapon_scene.set_meta("edited", false)
	SignalManager.ammo_selected.connect(set_ammunition_type)

func damage() -> float:
	c_fin_damage_comp()
	return fin_damage_flat * fin_damage_mult

func accuracy() -> float:
	c_fin_accuracy_comp()
	var combined_accuracy : float = fin_accuracy_flat * fin_accuracy_mult
	if (combined_accuracy) > 100.0:
		combined_accuracy = 100
	return (combined_accuracy)

func usable_accuracy() -> float:
	c_fin_accuracy_comp()
	var combined_accuracy : float = fin_accuracy_flat * fin_accuracy_mult
	if (combined_accuracy) > 100.0:
		combined_accuracy = 100
	return (100.0 - combined_accuracy)

func reload_time() -> float:
	c_fin_reload_comp()
	if fin_reload_mult <= 0.0:
		fin_reload_mult = 0.0001
	return (fin_reload_time_flat * fin_reload_mult)

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

#region calculation
func calc_accuracy(value : float) -> float:
	if value > 100.0:
		value = 100
	return (100.0 - value)/10

func calculate_muzzle_point() -> Vector3:
	#das berechnet ne primitive bounding box um das mesh herum und gibt mir die größe in jede richtung als vector3, woraus ich dann die länge des jeweiligen barrels ermitteln kann :D
	var aabb : AABB
	if barrel_mesh == null:
		aabb = AABB()
	else:
		aabb = barrel_mesh.get_aabb()
	var true_size = aabb.size 
	return barrel_socket + Vector3(0.0, 0.0, true_size.z)
