extends Node2D

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var interactable_label_component: Control = $InteractableLabelComponent


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_activated)
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)
	
	interactable_label_component.hide()
	
func on_interactable_activated() -> void:
	interactable_label_component.show()
	
func on_interactable_deactivated() -> void:
	interactable_label_component.hide()
