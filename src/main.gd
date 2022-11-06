extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("server") or OS.has_feature("Server"): 
		server_main()
	else:
		client_main()
	return


func client_main() -> void:
	register_singleton("res://src/client/c_globals.tscn")
	get_tree().change_scene_to_file("res://src/client/main_menu.tscn")
	return


func server_main() -> void:
	pass


func register_singleton(path: String) -> void:
	var inst = load(path).instantiate()
	get_tree().root.call_deferred("add_child", inst)
	return
