extends Node

signal quit_request
var pop_up
var wait_release: Dictionary = {}
func _unhandled_key_input(event):
    prints(event)
    if Input.is_action_just_released("ui_cancel"):
        _on_Back_pressed()


func _notification(what):
    if what == NOTIFICATION_WM_GO_BACK_REQUEST:
        _on_Back_pressed()
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        get_tree().quit()


func _on_Back_pressed():
    quit_request.emit()
    pass		
