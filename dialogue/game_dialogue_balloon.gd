extends BasicGameDialogueBalloon

@onready var emotes_panel: Panel = $Balloon/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/EmotesPanel

func start(with_dialogue_resource: DialogueResource = null, title: String = "", extra_game_states: Array = []) -> void:
	super(with_dialogue_resource, title, extra_game_states)
	emotes_panel.play_emote("emote_12_talking")
	
func next(next_id: String) -> void:
	super(next_id)
	emotes_panel.play_emote("emote_12_talking")
