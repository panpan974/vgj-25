extends Node2D

var players = {}

func _input(event):
  var deviceId = event.device

  ## Check to see that that event id on an action
  if not players.get(deviceId) and event.is_action_pressed("start"):

	## create the player scene instance
	var playerScene = preload("res://scenes/player.tscn")
	var player = playerScene.instantiate()

	## give it a name so it's unique, if you really want
	player.set_name('player' + str(deviceId))
	
	## Give the player instance a device id so it can handle its own events
	player.deviceId = deviceId
	## register the player in the players dict
	players[deviceId] = player
	
	## Add the player to the scene
	add_child(player)
