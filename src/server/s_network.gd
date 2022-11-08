extends Node

var peer: ENetMultiplayerPeer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("game server starting")
	self.peer = ENetMultiplayerPeer.new()
	self.peer.create_server(9090)
	self.multiplayer.multiplayer_peer = self.peer
	return


func _process(delta: float) -> void:
	pass
