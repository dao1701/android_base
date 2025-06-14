extends Node

signal quit_request
var pop_up
var wait_release: Dictionary = {}
func _unhandled_key_input(event):
    if Input.is_action_just_released("ui_cancel"):
        wait_release["ui_cancel"] = false
    if Input.is_action_pressed("ui_cancel") and wait_release.get("ui_cancel", false) == false:
        wait_release["ui_cancel"] = true
        _on_Back_pressed()


func _notification(what):
    if what == NOTIFICATION_WM_GO_BACK_REQUEST:
        _on_Back_pressed()
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        get_tree().quit()


func _on_Back_pressed():
    quit_request.emit()
    pass		
