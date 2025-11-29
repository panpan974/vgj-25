extends Sprite3D

func _process(delta):
    var camera = get_viewport().get_camera_3d()
    if camera:
        look_at(camera.global_transform.origin, Vector3.UP)
        # Empêche le sprite de tourner sur X et Z (reste vertical)
        rotation.x = 0
        rotation.z = 0