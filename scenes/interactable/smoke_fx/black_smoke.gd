extends GPUParticles3D

var interactable: Interactable

func _ready() -> void:
    interactable = get_parent() as Interactable
    interactable.on_broken_state_changed.connect(_on_broken_state_changed)

func _on_broken_state_changed(state: bool) -> void:
    emitting = state