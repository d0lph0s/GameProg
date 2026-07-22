extends Node3D

var platform_NODE : Node3D

var platform_mesh : PackedScene = preload("uid://b4wcc0ej50o7u")
var barrel_mesh : PackedScene = preload("uid://dggehpa1xc4l4")
var slide_mesh : PackedScene = preload("uid://cf6uagrdjie38")
var magazine_mesh : PackedScene = preload("uid://vtmo0cw83m4t")
var trigger_mesh : PackedScene = preload("uid://cwypnwf4c7eia")
var ammunition_mesh : PackedScene = preload("uid://b82nec2sh5hok")
var pumphandle_mesh : PackedScene = preload("uid://84ndlfvxgif4")
var sight_mesh : PackedScene = preload("uid://2f1srkg64ga")
var muzzle_mesh : PackedScene = preload("uid://be54lr7aqqeg7")

#workables
var platform : Node
var magazine : Node
var ammunition : Node
var pumphandle : Node
var barrel : Node
var slide : Node
var sight : Node
var muzzle : Node
var trigger : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	platform_NODE = $Platform
	platform = platform_mesh.instantiate()
	if(WeaponManager.weapon_components["Platform"] != null):
		load_weapon()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_weapon() -> void:
	if($WeaponsMenu.visible == true):
		WeaponManager.export_parameters()
	if (WeaponManager.weapon_components["Platform"] == null || WeaponManager.weapon_components["Platform"] == 0):
		_on_platform_options_item_selected(1)
	else:
		_on_platform_options_item_selected(WeaponManager.weapon_components["Platform"])
	await get_tree().process_frame
	
	if WeaponManager.weapon_components["Magazine"] == null:
		_on_magazine_p_options_item_selected(1)
	
	#look for where null or 0 is asked for!
	if WeaponManager.weapon_components["Magazine"] == null || WeaponManager.weapon_components["Magazine"] == 0:
		_on_magazine_p_options_item_selected(0)
	
	match WeaponManager.weapon_components["Platform"]:
		1, 2:
			_on_magazine_p_options_item_selected(WeaponManager.weapon_components["Magazine"])
		3:
			_on_magazine_a_options_item_selected(WeaponManager.weapon_components["Magazine"])
		4:
			_on_magazine_s_options_item_selected(WeaponManager.weapon_components["Magazine"])
	await get_tree().process_frame
	
		#maybe just magazine of 1
		
	if(WeaponManager.weapon_components["Platform"] == 4):
		if WeaponManager.weapon_components["PumpHandle"] == null:
			pass
		else:
			_on_pump_handle_options_item_selected(WeaponManager.weapon_components["PumpHandle"])
		
	if WeaponManager.weapon_components["Barrel"] == null || WeaponManager.weapon_components["Barrel"] == 0:
		_on_barrel_options_item_selected(0)
	else:
		_on_barrel_options_item_selected(WeaponManager.weapon_components["Barrel"])
	await get_tree().process_frame
	
	if WeaponManager.weapon_components["Ammunition"] == null || WeaponManager.weapon_components["Ammunition"] == 0:
		_on_ammunition_options_item_selected(1)
	else:
		_on_ammunition_options_item_selected(WeaponManager.weapon_components["Ammunition"])
	SignalManager.ammo_selected.emit()
	await get_tree().process_frame
	
	if(WeaponManager.weapon_components["Platform"] == 1 || WeaponManager.weapon_components["Platform"] == 2):
		if WeaponManager.weapon_components["Slide"] == null || WeaponManager.weapon_components["Slide"] == 0:
			_on_slide_options_item_selected(0)
		else:
			_on_slide_options_item_selected(WeaponManager.weapon_components["Slide"])
	
	if WeaponManager.weapon_components["Slide"] != null:
		if WeaponManager.weapon_components["Sight"] == null || WeaponManager.weapon_components["Sight"] == 0:
			_on_sight_p_options_item_selected(0)
		else:
			_on_sight_p_options_item_selected(WeaponManager.weapon_components["Sight"])
	
	if(WeaponManager.weapon_components["Platform"] == 1 || WeaponManager.weapon_components["Platform"] == 2):
		if WeaponManager.weapon_components["Barrel"] == 2:
			if WeaponManager.weapon_components["Muzzle"] == null || WeaponManager.weapon_components["Muzzle"] == 0:
				_on_muzzle_options_item_selected(0)
			else:
				_on_muzzle_options_item_selected(WeaponManager.weapon_components["Muzzle"])
		if WeaponManager.weapon_components["Trigger"] == null && WeaponManager.weapon_components["Trigger"] == 0:
			_on_trigger_options_item_selected(0)
		else:
			if WeaponManager.weapon_components["Trigger"] != null:
				_on_trigger_options_item_selected(WeaponManager.weapon_components["Trigger"])
	
	
	$WeaponFunctionality.process_mode = Node.PROCESS_MODE_INHERIT
	$WeaponFunctionality.active = true
	$WeaponFunctionality.load_muzzle_flash()
	$WeaponFunctionality.start()
	

#ich hasse diese function (Grüße vom 22.07.2026 00:31 Uhr)
func weapon_modified(type : int) -> void:
	WeaponManager.export_parameters()
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
			WeaponManager.barrel_socket = platform.find_child("*" + "Barrel" + "*").position
			#endregion 
		1:
			#region magazine"
			if magazine_mesh != null:
				PlayerManager.current_ammuniton = magazine_mesh
			var magazine_NODE = platform.get_child(0).find_child("Socket_Magazine" + "*")
			if(magazine_mesh == null):
				
				if(magazine == null || magazine.get_child_count() == 0):
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
			var ammunition_NODE
			if magazine != null:
				if magazine.get_child(0).get_child(0) != null:
					ammunition_NODE = magazine.get_child(0).get_child(0)
			if(ammunition_mesh == null):
				if(ammunition_NODE.get_child(0) != null):
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
				if pumphandle != null:
					if(pumphandle.get_child_count() == 0):
						return
					pumphandle_NODE.get_child(0).queue_free()
					return
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
				if barrel != null:
					if(barrel.get_child_count() == 0):
						return
					barrel_NODE.get_child(0).queue_free()
					return
				return
				
			if(barrel_NODE.get_child_count() != 0 && barrel_NODE.get_child(0) != null):
				barrel_NODE.get_child(0).queue_free()
			barrel = barrel_mesh.instantiate()
			barrel.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			barrel_NODE.add_child(barrel)
			WeaponManager.barrel_mesh = barrel.get_child(0).mesh
			#endregion
		5:
			#region slide
			var slide_NODE = platform.get_child(0).find_child("Socket_Slide" + "*", true)
			if(slide_mesh == null):
				if(slide != null):
					if(slide.get_child_count() == 0):
						return
					slide_NODE.get_child(0).queue_free()
					return
				return
				
			if(slide_NODE.get_child_count() != 0 && slide_NODE.get_child(0) != null):
				slide_NODE.get_child(0).queue_free()
			slide = slide_mesh.instantiate()
			slide.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			slide.get_child(0).get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			slide.get_child(0).get_child(0).set_surface_override_material(1, load("res://Art/3D/Weapons/Master_Material.material"))
			slide_NODE.add_child(slide)
			#endregion
		6:
			#region sight
			var sight_NODE
			if slide != null:
				sight_NODE = slide.find_child("Socket_Sight" + "*", true)
			if(sight_mesh == null):
				if sight != null:
					if(sight.get_child_count() == 0):
						return
					sight_NODE.get_child(0).queue_free()
					return
				return
				
			if(sight_NODE.get_child_count() != 0 && sight_NODE.get_child(0) != null):
				sight_NODE.get_child(0).queue_free()
			sight = sight_mesh.instantiate()
			#correction
			sight.position -= Vector3(0.0, 0.005, 0.0)
			sight.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			if(sight.get_child(0).get_child_count() != 0):
				sight.get_child(0).get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Lens_Material.material"))
			sight_NODE.add_child(sight)
			#endregion
		7:
			#region muzzle
			var muzzle_NODE
			if slide != null:
				muzzle_NODE = barrel.find_child("Socket_Muzzle", true)
			if(muzzle_mesh == null):
				if muzzle != null:
					if(muzzle.get_child_count() == 0):
						return
					muzzle_NODE.get_child(0).queue_free()
					return
				return
				
			if(muzzle_NODE.get_child_count() != 0 && muzzle_NODE.get_child(0) != null):
				muzzle_NODE.get_child(0).queue_free()
			muzzle = muzzle_mesh.instantiate()
			muzzle.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			muzzle_NODE.add_child(muzzle)
			#endregion
		8:
			#region trigger
			var trigger_NODE = platform.find_child("Socket_Trigger" + "*", true)
			if(trigger_mesh == null):
				if trigger != null:
					if(trigger.get_child_count() == 0):
						return
					trigger_NODE.get_child(0).queue_free()
					return
				return
				
			if(trigger_NODE.get_child_count() != 0 && trigger_NODE.get_child(0) != null):
				trigger_NODE.get_child(0).queue_free()
			trigger = trigger_mesh.instantiate()
			trigger.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			trigger_NODE.add_child(trigger)
			#endregion
	#region deprecated
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
	#endregion


func _on_platform_options_item_selected(index: int) -> void:
	match index:
		0: platform_mesh = null
		1: 
			platform_mesh = load("uid://b4wcc0ej50o7u")
			WeaponManager.weapon_damage = 12.0
			WeaponManager.weapon_accuracy = 50.0
			WeaponManager.weapon_reload_time = 2.25
		2: 
			platform_mesh = load("uid://cdbi5wdcrh8co")
			WeaponManager.weapon_damage = 10.0
			WeaponManager.weapon_accuracy = 60.0
			WeaponManager.weapon_reload_time = 2.0
		3: 
			platform_mesh = load("uid://dt0emhsqb3bvm")
			WeaponManager.weapon_damage = 8.0
			WeaponManager.weapon_accuracy = 40.0
			WeaponManager.weapon_reload_time = 3.25
		4: 
			platform_mesh = load("uid://cb3fdcg3h7ldb")
			WeaponManager.weapon_damage = 25.0
			WeaponManager.weapon_accuracy = 5.0
			WeaponManager.weapon_reload_time = 3.75
		_: return
	WeaponManager.weapon_components["Platform"] = index
	weapon_modified(0)

func _on_magazine_p_options_item_selected(index: int) -> void:
	match index:
		0: 
			magazine_mesh = null
			WeaponManager.magazine_size = 1
			WeaponManager.magazine_reload_mult = 0.3
		1: 
			magazine_mesh = load("uid://vtmo0cw83m4t")
			WeaponManager.magazine_size = 7
			WeaponManager.magazine_reload_mult = 0.9
		2: 
			magazine_mesh = load("uid://rfh3mntmk5q5")
			WeaponManager.magazine_size = 10
			WeaponManager.magazine_reload_mult = 1.1
		_: return
	WeaponManager.weapon_components["Magazine"] = index
	weapon_modified(1)

func _on_magazine_a_options_item_selected(index: int) -> void:
	match index:
		0: magazine_mesh = null
		1: magazine_mesh = load("uid://bnp8vwrfmmqvd")
		2: magazine_mesh = load("uid://jck0qe224oxk")
		3: magazine_mesh = load("uid://uceyaq8w3ul4")
		_: return
	WeaponManager.weapon_components["Magazine"] = index
	weapon_modified(1)

func _on_magazine_s_options_item_selected(index: int) -> void:
	match index:
		0: magazine_mesh = null
		1: magazine_mesh = load("uid://suuvkpfa4ocj")
		2: magazine_mesh = load("uid://bifthwb0lqptm")
		_: return
	WeaponManager.weapon_components["Magazine"] = index
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
	WeaponManager.weapon_components["Ammunition"] = index
	weapon_modified(2)

func _on_pump_handle_options_item_selected(index: int) -> void:
	match index:
		0: pumphandle_mesh = null
		1: pumphandle_mesh = load("uid://84ndlfvxgif4")
		2: pumphandle_mesh = load("uid://cu5yypsl2cp8f")
		3: pumphandle_mesh = load("uid://do6amjs7h4nhl")
		_: return
	WeaponManager.weapon_components["PumpHandle"] = index
	weapon_modified(3)

func _on_barrel_options_item_selected(index: int) -> void:
	match index:
		0: 
			barrel_mesh = null
			WeaponManager.barrel_damage_mult = 0.0
			WeaponManager.barrel_accuracy_mult = 0.2
		1: 
			barrel_mesh = load("uid://dilq3y31dtass")
			WeaponManager.barrel_damage_mult = 1.0
			WeaponManager.barrel_accuracy_mult = 1.1
			
		2: 
			barrel_mesh = load("uid://bl6d5fwvfhn47")
			WeaponManager.barrel_damage_mult = 0.9
			WeaponManager.barrel_accuracy_mult = 1.0
		3: 
			barrel_mesh = load("uid://cx2rfuc4uia2r")
			WeaponManager.barrel_damage_mult = 1.1
			WeaponManager.barrel_accuracy_mult = 1.25
		4: 
			barrel_mesh = load("uid://dggehpa1xc4l4")
			WeaponManager.barrel_damage_mult = 1.15
			WeaponManager.barrel_accuracy_mult = 1.05
		5: 
			barrel_mesh = load("uid://cnrw24clwicr2")
			WeaponManager.barrel_damage_mult = 1.45
			WeaponManager.barrel_accuracy_mult = 0.45
		6: 
			barrel_mesh = load("uid://fxyfxrjto6cv")
			WeaponManager.barrel_damage_mult = 1.5
			WeaponManager.barrel_accuracy_mult = 0.4
		_: return
	WeaponManager.weapon_components["Barrel"] = index
	weapon_modified(4)

func _on_slide_options_item_selected(index: int) -> void:
	match index:
		0: 
			slide_mesh = null
			WeaponManager.slide_reload_mult = 1.0
		1: 
			slide_mesh = load("uid://wrbw77g0kvbo")
			WeaponManager.slide_reload_mult = 0.95
		2: 
			slide_mesh = load("uid://cf6uagrdjie38")
			WeaponManager.slide_reload_mult = 0.9
	WeaponManager.weapon_components["Slide"] = index
	weapon_modified(5)

func _on_sight_p_options_item_selected(index: int) -> void:
	match index:
		0: 
			sight_mesh = null
			WeaponManager.sight_accuracy = 1.0
		1: 
			sight_mesh = load("uid://2f1srkg64ga")
			WeaponManager.sight_accuracy = 5.0
		2: 
			sight_mesh = load("uid://bnatebxjb77hv")
			WeaponManager.sight_accuracy = 7.5
		3: 
			sight_mesh = load("uid://ba0qfeugjq7xo")
			WeaponManager.sight_accuracy = 6.9
	WeaponManager.weapon_components["Sight"] = index
	weapon_modified(6)

func _on_muzzle_options_item_selected(index: int) -> void:
	match index:
		0: 
			muzzle_mesh = null
			WeaponManager.muzzle_damage_mult = 1.0
			WeaponManager.muzzle_accuracy_mult = 1.0
		1: 
			muzzle_mesh = load("uid://be54lr7aqqeg7")
			WeaponManager.muzzle_damage_mult = 0.85
			WeaponManager.muzzle_accuracy_mult = 1.7
		2: 
			muzzle_mesh = load("uid://bq1btucugyruw")
			WeaponManager.muzzle_damage_mult = 0.95
			WeaponManager.muzzle_accuracy_mult = 1.15
		3: 
			muzzle_mesh = load("uid://bmevrocnbn8ul")
			WeaponManager.muzzle_damage_mult = 1.2
			WeaponManager.muzzle_accuracy_mult = 0.95
	WeaponManager.weapon_components["Muzzle"] = index
	weapon_modified(7)

func _on_trigger_options_item_selected(index: int) -> void:
	match index:
		0: trigger_mesh = null
		1: trigger_mesh = load("uid://cwypnwf4c7eia")
		2: trigger_mesh = load("uid://bfyxa366bacjf")
	WeaponManager.weapon_components["Trigger"] = index
	weapon_modified(8)
