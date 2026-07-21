extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.enemy_killed.connect(enemy_killed)
	SignalManager.damage_taken.connect(damage_taken)
	SignalManager.ammo_selected.connect(ammo_selected)
	SignalManager.ammo_used.connect(ammo_used)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%Timer.text = str(GameManager.actual_time)

func enemy_killed() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	$HBoxContainer/VBoxContainerMain/RemainingE.text = "Rentner übrig: " + str(GameManager.enemy_count)

func damage_taken() -> void:
	$HBoxContainer/VBoxContainerMain/VBoxContainer/HealthBar.value = PlayerManager.current_health

func ammo_selected(ammo_name : StringName) -> void:
	match ammo_name:
		_ when "5" in ammo_name:
			%AmmoText.texture = load("res://Art/2D/UI/5_ammobox.png")
		_ when "9" in ammo_name:
			%AmmoText.texture = load("res://Art/2D/UI/9_ammobox.png")
		_ when "12" in ammo_name:
			%AmmoText.texture = load("res://Art/2D/UI/12_ammobox.png")
	
	pass

func ammo_used() -> void:
	%Ammo.text = str(PlayerManager.current_ammo)
