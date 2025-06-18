extends Node

signal load_finished(result: int)


# Called when the node enters the scene tree for the first time.
func download(link, path):
	prints("Download ", link)
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(self._http_request_completed)
	http.set_download_file(path)
	var request = http.request(link)
	if request != OK:
		push_error("Http request error")
	await http.request_completed
	remove_child(http)


func _http_request_completed(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Download Failed")
	load_finished.emit(result)


func save(content):
	var file: FileAccess = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	file.store_string(content)


func load_data(path = "user://save_game.dat" ) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null: return ""
	var content: String = file.get_as_text()
	return content

var aes = AESContext.new()


func hex_to_bytes(hex_string: String) -> PackedByteArray:
	var bytes: PackedByteArray = PackedByteArray()
	for i in range(0, hex_string.length(), 2):
		var hex_byte: String = hex_string.substr(i, 2)
		bytes.append(hex_byte.hex_to_int())
	return bytes


func decrypt_pck(encrypted_pck_path: String) -> bool:
	# Check if source file exists
	if not FileAccess.file_exists(encrypted_pck_path):
		print("Error: Encrypted PCK file not found")
		return false

	var file: FileAccess = FileAccess.open(encrypted_pck_path, FileAccess.READ)
	if file == null:
		print("Error: Cannot open encrypted PCK file")
		return false

	var encrypted_data: PackedByteArray = file.get_buffer(file.get_length())
	print("File size: ", file.get_length())
	file.close()

	# Convert hex strings to proper byte arrays
	var key: PackedByteArray = hex_to_bytes(ProjectSettings.get_setting("encryption/key"))
	var iv: PackedByteArray  = hex_to_bytes(ProjectSettings.get_setting("encryption/iv"))

	# Start AES decryption
	var result = aes.start(AESContext.MODE_CBC_DECRYPT, key, iv)
	if result != OK:
		print("Error: Failed to start AES decryption")
		return false

	# Decrypt the data
	var decrypted_data = aes.update(encrypted_data)

	# Save decrypted PCK
	file = FileAccess.open("user://temp.pck", FileAccess.WRITE)
	if file == null:
		print("Error: Cannot create temp PCK file")
		return false

	file.store_buffer(decrypted_data)
	file.close()

	# Load decrypted PCK
	var load_result: bool = ProjectSettings.load_resource_pack("user://temp.pck")
	if not load_result:
		print("Error: Failed to load decrypted PCK")

	return load_result


func _ready() -> void:
	prints(ProjectSettings.get_setting("encryption/key"))
	if OS.has_feature("editor"):
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://src/main.tscn")
		return
	#load new version
	var version_apk: String = self.load_data("res://version")
	var new_version_apk: bool         = await check_new_version(version_apk)
	if new_version_apk: return

	var version: String  = self.load_data()
	var path_pck: String = "user://project.encrypted.pck"
	var new_version      = await get_new_version()
	if version != new_version:
		prints("No Patch")
		save(new_version)
		var url = ProjectSettings.get_setting("addons/source_url")
		download(url + "/project.encrypted.pck", path_pck)
		var code = await load_finished
		if code != OK:
			prints("Download Failed")
			return
	else:
		prints("Up to date")
	var check: bool = decrypt_pck(path_pck)
	prints("Load PCK ", check)
	get_tree().change_scene_to_file("res://src/main.tscn")

	print("OK")


func check_new_version(version_apk: String) -> bool:
	var url = ProjectSettings.get_setting("addons/source_url")
	prints("Version apk ", version_apk)
	var version_apk_path: String = "user://version"
	await download(url + "/version", version_apk_path)
	var new_version_apk: String = load_data(version_apk_path)
	if version_apk != new_version_apk:
		prints("New version apk available")
		return true
	else:
		prints("Up to date Version apk")
		return false

func get_new_version() -> String:
	var url = ProjectSettings.get_setting("addons/source_url")
	download(url + "/version.json", "user://patch.dat")
	await load_finished
	var string: String  = self.load_data("user://patch.dat")
	var json            = JSON.parse_string(string)
	var version: String = json["commit"]
	prints("Remote Message", json["lastCommitMessage"])
	return version
