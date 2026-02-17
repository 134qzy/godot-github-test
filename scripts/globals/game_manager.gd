extends Node


func start_game() -> void:
	SceneManager.load_main_scene_container()
	SceneManager.load_level("Level1")
	
func exit_game() -> void:
	get_tree().quit()
