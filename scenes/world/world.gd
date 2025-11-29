extends Node3D


func _ready() -> void:
	GameRecuperator.on_rotate.connect(_rotate_world)
	
func _rotate_world(direction: int):
	# Rotate the world around the car point
	var car = GameRecuperator.get_car()
	if car:
		var pivot = car.get_top_car()
		if pivot:
			var pivot_pos = pivot.global_transform.origin
			var transform_to_pivot = Transform3D(Basis(), -pivot_pos)
			var transform_back = Transform3D(Basis(), pivot_pos)
			global_transform = transform_back * Transform3D(Basis(Vector3.UP, 2 * direction * deg_to_rad(1)), Vector3()) * transform_to_pivot * global_transform

func _process(delta: float) -> void:
	# Move at the speed of the car in the opposite direction to simulate car movement
	var car = GameRecuperator.get_car()
	if car:
		var forward_dir = car.global_transform.basis.z.normalized()
		global_transform.origin += forward_dir * car.move_speed * delta
