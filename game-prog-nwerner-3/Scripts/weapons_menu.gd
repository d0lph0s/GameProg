extends Control

@onready var weapon_body_parts: VBoxContainer = $HBoxContainer/CenterContainerLeft/ScrollContainer/VScrollBar/WeaponBodyParts
@onready var weapon_extras: VBoxContainer = $HBoxContainer/CenterContainerRight/ScrollContainer/VScrollBar/WeaponExtras

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func body_part_selected(index : int) -> void:
	for i : int in range(1, 4):
		weapon_body_parts.get_child(i).visible = true
	for i : int in range(1, 4):
		#weapon_body_parts.get_child(i).mouse_filter = MOUSE_FILTER_IGNORE
		weapon_body_parts.get_child(i).visible = false
		#irtgendwas player feedback
	if (index == 0):
		index = 1
	if(index == 3):
		show_certain_part(5)
	else:
		hide_certain_part(5)
	show_certain_part(index)
	show_certain_part(6)

func show_certain_part(index : int) -> void:
	weapon_body_parts.get_child(index).visible = true

func hide_certain_part(index : int) -> void:
	weapon_body_parts.get_child(index).visible = false

func _on_platform_options_item_selected(index: int) -> void:
	if(index == 0):
		for i : int in range(1, weapon_body_parts.get_child_count()):
			weapon_body_parts.get_child(i).find_child("*" + "Options").selected = 0
			weapon_body_parts.get_child(i).visible = false
		return
	if(index != 0):
		show_certain_part(5)
	else:
		hide_certain_part(5)
	body_part_selected(index-1)

func _on_magazine_p_options_item_selected(index: int) -> void:
	if(index == 0): 
		hide_certain_part(4)
		return
	show_certain_part(4)

func _on_magazine_a_options_item_selected(index: int) -> void:
	if(index == 0): 
		hide_certain_part(4)
		return
	show_certain_part(4)

func _on_magazine_s_options_item_selected(index: int) -> void:
	if(index == 0): 
		hide_certain_part(4)
		return
	show_certain_part(4)


func _on_confirm_pressed() -> void:
	get_parent().visible = false
	get_parent().mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
