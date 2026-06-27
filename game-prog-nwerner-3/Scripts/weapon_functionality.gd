extends Node3D

var active : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!active):
		return
	if (Input.is_action_just_pressed("Shoot")):
		var rigidbody : RigidBody3D
		var collider : CollisionShape3D
		
		var bullet : Node3D = PlayerManager.current_ammuniton.instantiate()
		bullet.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
		var weapon_origin = find_parent("Player").find_child("WeaponOriginPistol")
		bullet.look_at_from_position(position, weapon_origin.global_transform.basis.z)
		bullet.global_transform = weapon_origin.global_transform
		bullet.rotation.x += deg_to_rad(90.0)
		bullet.scale = bullet.scale * 1.5
		
		rigidbody = RigidBody3D.new()
		rigidbody.mass = 0.02
		rigidbody.gravity_scale = 0.0
		shit
		rigidbody.collision_mask = (1 << 3 - 1 | 2 << 1 -1) #die masken scheinen nicht zu stimmen
		rigidbody.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
		rigidbody.contact_monitor = true
		rigidbody.set_script(load("res://Scripts/bullet_script.gd"))
		
		
		collider = CollisionShape3D.new()
		collider.shape = load("res://Art/3D/Weapons/Collider/bullet_shape.tres")
		
		rigidbody.add_child(collider)
		rigidbody.add_child(bullet)
		
		rigidbody.linear_velocity = weapon_origin.global_transform.basis.z * 1.0
		get_tree().root.add_child(rigidbody)



func _on_confirm_pressed() -> void:
	active = true
