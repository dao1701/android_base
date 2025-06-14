extends Node

signal quit_request
var pop_up_quit = preload("res://src/pop_up_quit.tscn")
var pop_up
func _unhandled_key_input(event):
    if Input.is_action_pressed("ui_cancel"):
        _on_Back_pressed()


func _notification(what):
    if what == NOTIFICATION_WM_GO_BACK_REQUEST:
        _on_Back_pressed()
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        get_tree().quit()


func _on_Back_pressed():
    prints("Quit Request")
    quit_request.emit()
    pass		


func _on_quit_request():
    if pop_up!= null:
        remove_child(pop_up)
    pop_up = pop_up_quit.instantiate()
    add_child(pop_up)
    pass # Replace with function body.
