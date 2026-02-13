class_name FeedComponent
extends Area2D

signal feed_received(area: Area2D )

func _on_area_entered(area: Area2D) -> void:
	feed_received.emit(area)
