extends Control
var exit_pop_up: BasePopUp

func _on_event_listener_quit_request() -> void:
    if exit_pop_up != null:
        exit_pop_up.exit()
        return
    var async_load = AsyncScene.new("res://src/exit_pop_up/pop_up_quit.tscn", self, AsyncScene.LoadingSceneOperation.Additive)
    await async_load.OnComplete
    async_load.ChangeScene()
    exit_pop_up = async_load.currentSceneNode
    exit_pop_up.tree_exited.connect(on_close_pop_up.bind(exit_pop_up))
    pass # Replace with function body.


func on_close_pop_up(pop_up: Control):
    prints("Close Pop Up ",pop_up.name)
