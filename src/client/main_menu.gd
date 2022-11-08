extends Node3D


@onready var c_globals: C_Globals = get_node("/root/C_Globals")
@onready var c_network: C_Network = get_node("/root/C_Network")

@export var ui_tab_container: TabContainer
@export var username_linedit: LineEdit
@export var password_linedit: LineEdit
@export var login_button: Button
@export var error_label: Label

@export var characters_itemlist: ItemList

@export var create_character_popup_panel: PopupPanel
@export var character_name_line_edit: LineEdit
@export var create_character_button: Button

@export var join_button: Button

@export var animation_player: AnimationPlayer

var player_characters = {}

func _asserts() -> void:
	assert(!(c_globals == null))
	assert(!(c_network == null))

	assert(!(ui_tab_container == null))
	assert(!(username_linedit == null))
	assert(!(password_linedit == null))
	assert(!(login_button == null))
	assert(!(error_label == null))

	assert(!(characters_itemlist == null))
	
	assert(!(create_character_popup_panel == null))
	assert(!(character_name_line_edit == null))
	assert(!(create_character_button == null))

	assert(!(create_character_button == null))
	
	assert(!(join_button == null))
	return


func _ready() -> void:
	self._asserts()
	return


func _on_login_button_pressed() -> void:
	var username := username_linedit.text
	var password := password_linedit.text
	if username != "" and password != "":
		self.login_button.disabled = true
		var http_request = HTTPRequest.new()
		add_child(http_request)
		# Perform a POST request. The URL below returns JSON as of writing.
		# Note: Don't make simultaneous requests using a single HTTPRequest node.
		# The snippet below is provided for reference only.
		var req_body = JSON.new().stringify({"username": username, "password": password})
		var error = http_request.request("http://127.0.0.1:8000/api/auth/login/", ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, req_body)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
		
		
		var response = await http_request.request_completed
		var status_code: int = response[1]
		if status_code == 200:
			self.error_label.text = "Success"
			var json := JSON.new()
			json.parse(response[3].get_string_from_utf8())
			var body = json.get_data()
			c_globals.auth_token = body["key"]
			self.animation_player.play("Authenticated")
			self.ui_tab_container.current_tab = 1
			fetch_characters_list()
		else:
			self.error_label.text = "Failed"
			self.login_button.disabled = false
		http_request.queue_free()
	return


func fetch_characters_list() -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var headers = ["Content-Type: application/json", "Authorization: Token " + c_globals.auth_token ]
	var error = http_request.request("http://127.0.0.1:8000/api/data/characters/", headers)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	var response = await http_request.request_completed
	var status_code: int = response[1]
	if status_code == 200:
		var json := JSON.new()
		json.parse(response[3].get_string_from_utf8())
		var body = json.get_data()
		for b in body:
			self.player_characters[b['id']] = b['name']
		_show_characters()
	return


func _show_characters() -> void:
	characters_itemlist.clear()
	for c in self.player_characters.values():
		characters_itemlist.add_item(c)
	return


func _on_new_character_button_pressed() -> void:
	self.create_character_button.disabled = false
	self.create_character_popup_panel.popup_centered(Vector2(200,100))
	return


func _on_create_character_button_pressed() -> void:
	self.create_character_button.disabled = true
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var headers = ["Authorization: Token " + c_globals.auth_token, "Content-Type: application/json"]
	var req_body = JSON.new().stringify({"name": self.character_name_line_edit.text })
	print(req_body)
	var error = http_request.request("http://127.0.0.1:8000/api/data/characters/", headers, true, HTTPClient.METHOD_POST, req_body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	var response = await http_request.request_completed
	var status_code: int = response[1]
	if status_code == 201:
		fetch_characters_list()
	self.create_character_popup_panel.hide()
	self.character_name_line_edit.clear()
	return


func _on_characters_item_list_item_selected(index: int) -> void:
	$MeshInstance3D3.visible = true
	$UITabContainer/CharacterMenu/JoinButton.disabled = false
	return


func _on_join_button_pressed() -> void:
	self.join_button.disabled = true
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var headers = ["Authorization: Token " + c_globals.auth_token]
	var error = http_request.request("http://127.0.0.1:8000/api/matchmaking/get_game_server_instance/")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	var response = await http_request.request_completed
	var status_code: int = response[1]
	self.c_network.connect_to_server("127.0.0.1", 9090)
	if status_code == 200:
		print(response[3].get_string_from_utf8())
		### After here we can connect to a game server with the provided ip:port from the matchmaking
