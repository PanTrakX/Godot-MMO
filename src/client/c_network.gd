class_name C_Network
extends Node

var peer: ENetMultiplayerPeer 

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	return

func connect_to_server(ip: String, port: int) -> void:
	self.peer = ENetMultiplayerPeer.new()
	self.peer.create_client(ip, port)
	self.multiplayer.multiplayer_peer = self.peer 
	return

func _on_connected_to_server() -> void:
	print("CONNECTED")
	get_tree().change_scene_to_file("res://src/map.tscn")
	return
