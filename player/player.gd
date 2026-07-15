extends CharacterBody2D

@export var speed: float = 250.0
@export var acceleration: float = 0.2 # Gia tốc di chuyển mượt mà

var speed_multiplier: float = 1.0

var nearby_interactables: Array[Interactable] = []
var current_interactable: Interactable = null

@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	add_to_group("Player")
	prompt_label.hide()
	
	# Kết nối tín hiệu của Area2D quét tương tác
	$InteractionDetector.area_entered.connect(_on_interaction_area_entered)
	$InteractionDetector.area_exited.connect(_on_interaction_area_exited)
	
	# Kiểm tra vị trí spawn toàn cục từ Global
	if Global.player_spawn_name != "":
		var spawn_node = get_tree().current_scene.find_child(Global.player_spawn_name, true, false)
		if spawn_node and spawn_node is Marker2D:
			global_position = spawn_node.global_position
			print("Player spawned at: ", Global.player_spawn_name, " position: ", spawn_node.global_position)
		else:
			print("Warning: Spawn point node '", Global.player_spawn_name, "' not found!")
		Global.player_spawn_name = ""

var facing_direction: Vector2 = Vector2.DOWN

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2.ZERO
	
	# Điều khiển WASD và phím mũi tên
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		input_dir.y += 1
		
	if input_dir != Vector2.ZERO:
		facing_direction = input_dir.normalized()
		if has_node("Flashlight"):
			get_node("Flashlight").rotation = facing_direction.angle()
		
	var target_velocity = input_dir.normalized() * (speed * speed_multiplier)
	velocity = velocity.lerp(target_velocity, acceleration)


	move_and_slide()


# Bắt tín hiệu nhấn phím tương tác một lần duy nhất (không spam khi giữ đè phím)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_E or event.keycode == KEY_ENTER:
			if current_interactable and current_interactable.is_active:
				current_interactable.interact(self)
				# Cập nhật lại nhãn gợi ý (nhỡ sau khi tương tác đối tượng bị tắt/vô hiệu hóa)
				_update_closest_interactable()

func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("Interactable") and area is Interactable:
		nearby_interactables.append(area)
		_update_closest_interactable()

func _on_interaction_area_exited(area: Area2D) -> void:
	if area in nearby_interactables:
		nearby_interactables.erase(area)
		_update_closest_interactable()

# Tìm đối tượng tương tác gần người chơi nhất để hiển thị gợi ý
func _update_closest_interactable() -> void:
	# Loại bỏ các đối tượng đã bị xóa khỏi scene (queue_free)
	nearby_interactables = nearby_interactables.filter(func(a): return is_instance_valid(a))
	
	if nearby_interactables.is_empty():
		current_interactable = null
		prompt_label.hide()
		return
		
	var closest: Interactable = nearby_interactables[0]
	var min_dist = global_position.distance_squared_to(closest.global_position)
	for i in range(1, nearby_interactables.size()):
		var dist = global_position.distance_squared_to(nearby_interactables[i].global_position)
		if dist < min_dist:
			min_dist = dist
			closest = nearby_interactables[i]
			
	current_interactable = closest
	if current_interactable.is_active:
		prompt_label.text = current_interactable.prompt_message
		prompt_label.show()
	else:
		prompt_label.hide()
