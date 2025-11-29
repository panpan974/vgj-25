extends Node

@export var bg_music: AudioStream

func _ready() -> void:
    var soundPath = bg_music.resource_path
    SodaAudioManager.play_music(soundPath, true, false)
