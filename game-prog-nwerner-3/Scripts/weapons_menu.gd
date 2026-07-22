extends Control

@onready var weapon_body_parts: VBoxContainer = %WeaponBodyParts
@onready var weapon_extras: VBoxContainer = %WeaponExtras

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func flip_flop_of_death() -> void:
	print("Platform: " + str(%PlatformOptions.get_selected_id()))
	if %PlatformOptions.get_selected_id() == 0:
		print("PlatformFunction")
		for i : int in %WeaponBodyParts.get_child_count():
			if(i != 0):
				%WeaponBodyParts.get_child(i).get_child(0).get_child(1).selected = 0
				%WeaponBodyParts.get_child(i).hide()
		return
		
	if %Magazine_P.visible && %MagazinePOptions.get_selected_id() == 0 || %Magazine_A.visible && %MagazineAOptions.get_selected_id() == 0 || %Magazine_S.visible && %MagazineSOptions.get_selected_id() == 0:
		print("MagazineFunction")
		%AmmunitionOptions.selected = 0
		%Ammunition.hide()
		return
	
	if (%Barrel.visible && %BarrelOptions.get_selected_id() != 2):
		%Muzzle_P.hide()
		%MuzzleOptions.selected = 0
	
	if (%PlatformOptions.get_selected_id() != 1 && %PlatformOptions.get_selected_id() != 2):
		%Slide.hide()
		%SlideOptions.selected = 0
		%Trigger.hide()
		%TriggerOptions.selected = 0
	
	if (%PlatformOptions.get_selected_id() != 4):
		%PumpHandle.hide()
		%PumpHandleOptions.selected = 0
	
	if (%Slide.visible && %SlideOptions.get_selected_id() == 0 || %Slide.visible && %SlideOptions.get_selected_id() == 1):
		%Sight_P.hide()
		%SightPOptions.selected = 0
	
	if(%PlatformContainer.visible) && %PlatformOptions.get_selected_id() != 0:
		match %PlatformOptions.get_selected_id():
			0:
				pass
			1,2:
				%Magazine_P.show()
				%Magazine_A.hide()
				%Magazine_S.hide()
				%Slide.show()
			3:
				%Magazine_A.show()
				%Magazine_P.hide()
				%Magazine_S.hide()
			4:
				%Magazine_S.show()
				%Magazine_P.hide()
				%Magazine_A.hide()
				%PumpHandle.show()
				
		%Barrel.show()
	else:
		return
	
	if (%PlatformOptions.get_selected_id() == 1 || %PlatformOptions.get_selected_id() == 2):
		%Trigger.show()
	
	if (%Barrel.visible && %BarrelOptions.get_selected_id() == 2):
		%Muzzle_P.show()
	
	if(%Magazine_P.visible && %MagazinePOptions.get_selected_id() != 0 || %Magazine_A.visible && %MagazineAOptions.get_selected_id() != 0 || %Magazine_S.visible && %MagazineSOptions.get_selected_id() != 0):
		%Ammunition.show()
	
	if(%Slide.visible && %SlideOptions.get_selected_id() == 2):
		%Sight_P.show()

func show_left_part(index : int) -> void:
	weapon_body_parts.get_child(index).visible = true

func hide_left_part(index : int) -> void:
	weapon_body_parts.get_child(index).visible = false

func show_right_part(index : int) -> void:
	weapon_extras.get_child(index).visible = true

func hide_right_part(index : int) -> void:
	weapon_extras.get_child(index).visible = false

func _on_options_selected(index: int) -> void:
	flip_flop_of_death()


func _on_confirm_pressed() -> void:
	await get_tree().process_frame
	GameManager.weapon_menu.pack($"../..")
	WeaponManager.weapon_scene.pack($"../..")
	GameManager.load_level(GameManager.main_menu)
