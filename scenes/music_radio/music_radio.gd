extends Node

@export var bg_music: AudioStream
@export var car_idle_sound: AudioStream
@export var car_night_ambiance: AudioStream

func _ready() -> void:
    var soundPath = bg_music.resource_path
    SodaAudioManager.play_music(soundPath, true, false)
    # SodaAudioManager.play_sfx(car_night_ambiance.resource_path, true)
    # SodaAudioManager.play_sfx(car_idle_sound.resource_path,true)


