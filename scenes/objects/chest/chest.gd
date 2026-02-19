extends Node2D


var balloon_scene = preload("res://dialogue/game_dialogue_balloon.tscn")
var corn_harvest_scene = preload("res://scenes/objects/plants/corn_harvest.tscn")
var tomato_harvest_scene = preload("res://scenes/objects/plants/tomato_harvest.tscn")

@export var dialogue_start_command: String
@export var food_drop_height: int = 40
@export var reward_output_radius: int = 20
@export var output_reward_scene: Array[PackedScene] = []

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var feed_component: FeedComponent = $FeedComponent
@onready var reward_marker: Marker2D = $RewardMarker
@onready var interactable_label_component: Control = $InteractableLabelComponent

var in_range: bool
var is_chest_open: bool

func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_activated)
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)
	interactable_label_component.hide()
	
	GameDialogueManager.feed_the_animals.connect(on_feed_the_animals)
	feed_component.feed_received.connect(on_feed_received)
	
func on_interactable_activated() -> void:
	interactable_label_component.show()
	in_range = true
	
func on_interactable_deactivated() -> void:
	if is_chest_open:
		animated_sprite_2d.play("chest_close")
	
	is_chest_open = false
	interactable_label_component.hide()
	in_range = false
	
func _unhandled_input(event: InputEvent) -> void:
	if in_range:
		if event.is_action_pressed("show_dialogue"):
			interactable_label_component.hide()
			animated_sprite_2d.play("chest_open")
			is_chest_open = true
			
			var balloon: BasicGameDialogueBalloon = balloon_scene.instantiate()
			get_tree().root.add_child(balloon)
			balloon.start(load("res://dialogue/conversations/chest.dialogue"), dialogue_start_command)
			
func on_feed_the_animals() -> void:
	if in_range:
		trigger_feed_harvest("corn", corn_harvest_scene)
		trigger_feed_harvest("tomato", tomato_harvest_scene)
	
func trigger_feed_harvest(inventory_item: String, scene: Resource) -> void:
	var inventory:Dictionary = InventoryManager.inventory
	
	if !inventory.has(inventory_item):
		return
		
	var inventory_item_count = inventory[inventory_item]
	
	for index in inventory_item_count:
		var harvest_instance = scene.instantiate() as Node2D
		harvest_instance.global_position = Vector2(global_position.x, global_position.y - food_drop_height)
		get_tree().root.add_child(harvest_instance)
		var target_position = global_position
		
		var time_delay = randf_range(0.5, 2.0)
		await get_tree().create_timer(time_delay).timeout
		
		var tween = get_tree().create_tween()
		tween.tween_property(harvest_instance, "position", target_position, 1.0)
		tween.tween_property(harvest_instance, "scale", Vector2(0.5, 0.5), 1.0)
		tween.tween_callback(harvest_instance.queue_free)
		
		InventoryManager.remove_collectable(inventory_item)
		
func on_feed_received(area: Area2D) -> void:
	call_deferred("add_reward_scene")
		
func add_reward_scene() -> void:
	for scene in output_reward_scene:
		var reward_scene: Node2D = scene.instantiate()
		var reward_position: Vector2 = get_random_position_in_circle(reward_marker.global_position, reward_output_radius)
		reward_scene.global_position = reward_position
		get_tree().root.add_child(reward_scene)
		
func get_random_position_in_circle(center: Vector2, radius: int) -> Vector2i:
	var angle = randf() * TAU
	
	var distance_from_center = sqrt(randf()) * radius
	
	var x: int = center.x + distance_from_center * cos(angle)
	var y: int = center.y + distance_from_center * sin(angle)
	
	return Vector2i(x, y)
	
	# 实现奖励从宝箱弹出效果
	#func add_reward_scene() -> void:
	#for scene in output_reward_scene:
		#var reward_node: Node2D = scene.instantiate()
		## 初始位置设为宝箱的 Marker 位置
		#reward_node.global_position = reward_marker.global_position
		#get_tree().root.add_child(reward_node)
		#
		## 计算落地目标点
		#var target_pos = get_random_position_in_circle(reward_marker.global_position, reward_output_radius)
		#
		## 调用“发射”动画
		#launch_reward(reward_node, target_pos)
#
#func launch_reward(item: Node2D, target: Vector2):
	## 1. 创建一个 Tween
	#var tween = get_tree().create_tween()
	## 设置并行模式：让 X 轴和 Y 轴的动画同时进行
	#tween.set_parallel(true)
	#
	#var duration = 0.6 # 动画持续时间
	#var jump_height = randf_range(30.0, 50.0) # 随机跳跃高度
	#
	## --- 水平运动 (X轴) ---
	## 匀速移动到目标的 X 坐标
	#tween.tween_property(item, "global_position:x", target.x, duration).set_trans(Tween.TRANS_LINEAR)
	#
	## --- 垂直运动 (Y轴) ---
	## 我们需要创建一个序列，所以这里不直接在并行的 tween 里写 Y，而是另建一个或使用串联
	#var y_tween = get_tree().create_tween()
	## 第一阶段：向上跳 (Ease Out，模拟克服重力)
	#y_tween.tween_property(item, "global_position:y", target.y - jump_height, duration / 2.0)\
		#.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	## 第二阶段：向下掉 (Ease In，模拟重力加速)
	#y_tween.tween_property(item, "global_position:y", target.y, duration / 2.0)\
		#.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	#
	## --- 增强视觉效果的“果汁”(Juice) ---
	## 弹出时从小变大
	#item.scale = Vector2.ZERO
	#tween.tween_property(item, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	#
	## 弹出时带一点随机旋转
	#var random_rotation = randf_range(-PI, PI)
	#tween.tween_property(item, "rotation", random_rotation, duration)
