extends BasePopUp


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass


func _on_ok_pressed():
    get_tree().quit()
    pass # Replace with function body.


func exit():
    queue_free()

func _on_close_pressed():
    queue_free()
    pass # Replace with function body.
