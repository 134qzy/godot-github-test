extends NpcPlayableCharacter


func _ready() -> void:
	walk_cycles = randf_range(min_walk_cycle,max_walk_cycle)
