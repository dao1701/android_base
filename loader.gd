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
    var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
    file.store_string(content)


func load_data(path = "user://save_game.dat" ) -> String:
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null: return ""
    var content: String = file.get_as_text()
    return content


func _ready():
    #load new version
    if OS.get_name() == "Windows":
        await get_tree().create_timer(0.1).timeout
        get_tree().change_scene_to_file("res://src/main.tscn")
        return
    var version     = self.load_data()
    var path_pck    = "user://patch.pck"
    var new_version = await get_new_version()
    if version != new_version:
        prints("No Patch")
        save(new_version)
        download("https://gitlab.com/tvdlhp10tin/test/-/raw/main/patch.pck", path_pck)
        var code = await load_finished
        var file = FileAccess.open(path_pck, FileAccess.READ)
        if file == null:
            prints("No patch error")
            get_tree().quit(0)
    else:
        prints("Up to date")
    var check = ProjectSettings.load_resource_pack(path_pck)
    prints("Load PCK", check)
    get_tree().change_scene_to_file("res://src/main.tscn")

    print("OK")


func get_new_version():
    download("https://gitlab.com/api/v4/projects/52931934/repository/branches/main", "user://patch.dat")
    await load_finished
    var string  = self.load_data("user://patch.dat")
    var version = JSON.parse_string(string)["commit"]["short_id"]
    prints("New ", version)
    return version
