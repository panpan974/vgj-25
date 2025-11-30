extends Node


@export var bg_music: AudioStream
@export var car_idle_sound: AudioStream
@export var car_night_ambiance: AudioStream

# Listes de sons pour la radio
@export var radio_fuel: Array[AudioStream] = []
@export var radio_volant: Array[AudioStream] = []


var tank_broken: bool = false
var fuel_timer: Timer = null

func _ready() -> void:
    GameRecuperator.all_systems_ready.connect(_on_all_systems_ready)
    var soundPath = bg_music.resource_path
    SodaAudioManager.play_music(soundPath, true, false)
    # SodaAudioManager.play_sfx(car_night_ambiance.resource_path, true)
    # SodaAudioManager.play_sfx(car_idle_sound.resource_path,true)

func _on_all_systems_ready():
    var car = GameRecuperator.get_car()
    if car:
        car.fuel_tank.on_fuel_tank_broken.connect(play_sfx_fuel)
        car.fuel_tank.on_fuel_tank_repaired.connect(stop_sfx_fuel)

# Joue un son aléatoire de la liste radio_fuel
func play_sfx_fuel():
    tank_broken = true
    if radio_fuel.size() == 0:
        return
    var idx = randi() % radio_fuel.size()
    var stream = radio_fuel[idx]
    if stream:
        SodaAudioManager.play_sfx(stream.resource_path)

    # Lance ou relance le timer
    if not fuel_timer:
        fuel_timer = Timer.new()
        fuel_timer.wait_time = 10.0
        fuel_timer.one_shot = false
        add_child(fuel_timer)
        fuel_timer.timeout.connect(_on_fuel_timer_timeout)
    if not fuel_timer.is_stopped():
        fuel_timer.stop()
    fuel_timer.start()


func stop_sfx_fuel():
    tank_broken = false
    if fuel_timer:
        fuel_timer.stop()

func _on_fuel_timer_timeout():
    if tank_broken:
        play_sfx_fuel()

func play_sfx_volant():
    if radio_volant.size() == 0:
        return
    var idx = randi() % radio_volant.size()
    var stream = radio_volant[idx]
    if stream:
        SodaAudioManager.play_sfx(stream.resource_path)
