extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("server") or OS.has_feature("Server") or OS.get_cmdline_args()[0] == "server": 
		server_main()
	else:
		client_main()
	return


func client_main() -> void:
	register_singleton("res://src/client/c_globals.tscn")
	register_singleton("res://src/client/c_network.tscn")
	get_tree().change_scene_to_file("res://src/client/main_menu.tscn")
	return


func server_main() -> void:
	register_singleton("res://src/server/s_network.tscn")
	pass


func register_singleton(path: String) -> void:
	var inst = load(path).instantiate()
	get_tree().root.call_deferred("add_child", inst)
	return
