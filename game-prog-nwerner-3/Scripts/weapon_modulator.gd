extends Node3D

@onready var platform_NODE : Node3D = $Platform

var platform_mesh : PackedScene = preload("uid://b4wcc0ej50o7u")
var barrel_mesh : PackedScene = preload("uid://dggehpa1xc4l4")
var slide_mesh : PackedScene = preload("uid://cf6uagrdjie38")
var magazine_mesh : PackedScene = preload("uid://vtmo0cw83m4t")
var trigger_mesh : PackedScene = preload("uid://cwypnwf4c7eia")
var ammunition_mesh : PackedScene = preload("uid://b82nec2sh5hok")
var pumphandle_mesh : PackedScene = preload("uid://84ndlfvxgif4")

#workables
var platform : Node
var magazine : Node
var ammunition : Node
var pumphandle : Node
var barrel : Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	platform = platform_mesh.instantiate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func weapon_modified(type : int) -> void:
	match type:
		0:
			#region platform
			
			if(platform != null):
				if(platform_mesh == null):
					if(platform.get_child_count() == 0):
						return
					platform_NODE.get_child(0).queue_free()
					return
			if(platform_NODE.get_child_count() != 0 && platform_NODE.get_child(0) != null):
				platform_NODE.get_child(0).queue_free()
			platform = platform_mesh.instantiate()
			platform.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			platform_NODE.add_child(platform)
			#endregion 
		1:
			#region magazine"
			var magazine_NODE = platform.get_child(0).find_child("Socket_Magazine" + "*")
			if(magazine_mesh == null):
				
				if(magazine.get_child_count() == 0):
					return
				magazine_NODE.get_child(0).queue_free()
				return
			if(magazine_NODE.get_child_count() != 0 && magazine_NODE.get_child(0) != null):
				magazine_NODE.get_child(0).queue_free()
			magazine = magazine_mesh.instantiate()
			magazine.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			magazine_NODE.add_child(magazine)
			#endregion
		2:
			#region ammunition
			var ammunition_NODE = magazine.get_child(0).get_child(0)
			if(ammunition_mesh == null):
				ammunition_NODE.get_child(0).queue_free()
				return
			if(ammunition_NODE.get_child_count() != 0 && ammunition_NODE.get_child(0) != null):
				ammunition_NODE.get_child(0).queue_free()
			PlayerManager.current_ammuniton = ammunition_mesh
			ammunition = ammunition_mesh.instantiate()
			ammunition.rotation.x = deg_to_rad(90.0)
			ammunition.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			ammunition_NODE.add_child(ammunition)
			SignalManager.ammo_selected.emit(ammunition.name)
			#endregion
			#tween for style
		3:
			#region pumphandle
			var pumphandle_NODE = platform.get_child(0).get_child(8)
			if(pumphandle_mesh == null):
				if(pumphandle.get_child_count() == 0):
					return
				pumphandle_NODE.get_child(0).queue_free()
				return
			if(pumphandle_NODE.get_child_count() != 0 && pumphandle_NODE.get_child(0) != null):
				pumphandle_NODE.get_child(0).queue_free()
			pumphandle = pumphandle_mesh.instantiate()
			pumphandle.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			pumphandle_NODE.add_child(pumphandle)
			#endregion
		4:
			#region barrel
			var barrel_NODE = platform.get_child(0).find_child("Socket_Barrel" + "*", true)
			if(barrel_mesh == null):
				if(barrel.get_child_count() == 0):
					return
				barrel_NODE.get_child(0).queue_free()
				return
				
			if(barrel_NODE.get_child_count() != 0 && barrel_NODE.get_child(0) != null):
				barrel_NODE.get_child(0).queue_free()
			barrel = barrel_mesh.instantiate()
			barrel.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			barrel_NODE.add_child(barrel)
			#endregion
	"""
	
	#region slide
	var slide_NODE = platform.get_child(0).get_child(1)
	var slide = slide_mesh.instantiate()
	slide.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
	slide_NODE.add_child(slide)
	#endregion
	
	#region trigger
	var trigger_NODE = platform.get_child(0).get_child(3)
	var trigger = trigger_mesh.instantiate()
	trigger.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
	trigger_NODE.add_child(trigger)
	#endregion
	"""
	

func _on_platform_options_item_selected(index: int) -> void:
	match index:
		0: platform_mesh = null
		1: platform_mesh = load("uid://b4wcc0ej50o7u")
		2: platform_mesh = load("uid://cdbi5wdcrh8co")
		3: platform_mesh = load("uid://dt0emhsqb3bvm")
		4: platform_mesh = load("uid://cb3fdcg3h7ldb")
		_: return
	weapon_modified(0)

func _on_magazine_p_options_item_selected(index: int) -> void:
	match index:
		0: magazine_mesh = null
		1: magazine_mesh = load("uid://vtmo0cw83m4t")
		2: magazine_mesh = load("uid://rfh3mntmk5q5")
		_: return
	weapon_modified(1)

func _on_magazine_a_options_item_selected(index: int) -> void:
	match index:
		0: magazine_mesh = null
		1: magazine_mesh = load("uid://bnp8vwrfmmqvd")
		2: magazine_mesh = load("uid://jck0qe224oxk")
		3: magazine_mesh = load("uid://uceyaq8w3ul4")
		_: return
	weapon_modified(1)

func _on_magazine_s_options_item_selected(index: int) -> void:
	match index:
		0: magazine_mesh = null
		1: magazine_mesh = load("uid://suuvkpfa4ocj")
		2: magazine_mesh = load("uid://bifthwb0lqptm")
		_: return
	weapon_modified(1)

func _on_ammunition_options_item_selected(index: int) -> void:
	match index:
		0: ammunition_mesh = null
		2: ammunition_mesh = load("uid://b82nec2sh5hok")
		3: ammunition_mesh = load("uid://dlwmndw515wo")
		4: ammunition_mesh = load("uid://b1byx2k68id71")
		5: ammunition_mesh = load("uid://llgqlhrtgfr5")
		7: ammunition_mesh = load("uid://bjmksthah5td6")
		8: ammunition_mesh = load("uid://dvshbpfvkqs7h")
		9: ammunition_mesh = load("uid://nm2lsg62f48n")
		10: ammunition_mesh = load("uid://oox6g1jjjlaf")
		12: ammunition_mesh = load("uid://d0iebpo4wxqaq")
		13: ammunition_mesh = load("uid://ludl6myp6wpy")
		14: ammunition_mesh = load("uid://bu57d6cr4wagt")
		15: ammunition_mesh = load("uid://b7k2nj5qluavf")
		_: return
	weapon_modified(2)

func _on_pump_handle_options_item_selected(index: int) -> void:
	match index:
		0: pumphandle_mesh = null
		1: pumphandle_mesh = load("uid://84ndlfvxgif4")
		2: pumphandle_mesh = load("uid://cu5yypsl2cp8f")
		3: pumphandle_mesh = load("uid://do6amjs7h4nhl")
		_: return
	weapon_modified(3)

func _on_barrel_options_item_selected(index: int) -> void:
	match index:
		0: barrel_mesh = null
		1: barrel_mesh = load("uid://dilq3y31dtass")
		2: barrel_mesh = load("uid://bl6d5fwvfhn47")
		3: barrel_mesh = load("uid://cx2rfuc4uia2r")
		4: barrel_mesh = load("uid://dggehpa1xc4l4")
		5: barrel_mesh = load("uid://cnrw24clwicr2")
		6: barrel_mesh = load("uid://fxyfxrjto6cv")
		_: return
	weapon_modified(4)
