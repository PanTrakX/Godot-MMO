extends Node

var peer: ENetMultiplayerPeer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("game server starting")
	self.peer = ENetMultiplayerPeer.new()
	self.peer.create_server(9090)
	self.multiplayer.multiplayer_peer = self.peer
	return

func _on_peer_connected(id: int) -> void:
	spawn_player_character(id)
	return
	
func _on_peer_disconnected(id: int) -> void:
	destroy_player_character(id)
	return

func spawn_player_character(id: int) -> void:
	var inst := preload("res://src/player_character.tscn").instantiate() as PlayerCharacter
	inst.name = StringName(str(id))
	get_tree().current_scene.get_node("PlayerCharacters").add_child(inst, true)
	return

func destroy_player_character(id) -> void:
	get_tree().current_scene.get_node("PlayerCharacters").get_node(str(id)).queue_free()
	return
