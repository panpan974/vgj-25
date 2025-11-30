extends Camera3D

var car: Car

func _ready():
    GameRecuperator.register_camera(self)
    car = get_parent() as Car

func _process(delta: float) -> void:
    if car == null:
        return
    # Zoom based on car speed
    # print_debug("Car speed: ", car.linear_velocity.length())
    var target_fov = lerp(80.0, 110.0, car.linear_velocity.length() / 60.0)
    fov = lerp(fov, target_fov, 0.1)