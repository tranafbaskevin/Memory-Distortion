extends CharacterBody2D

@export var speed: float = 250.0
@export var acceleration: float = 0.2 # Tốc độ tăng tốc (giúp di chuyển mượt hơn)

func _ready() -> void:
	add_to_group("Player")
	# Kiểm tra xem có yêu cầu vị trí spawn cụ thể từ Global không
	if Global.player_spawn_name != "":
		var spawn_node = get_tree().current_scene.find_child(Global.player_spawn_name, true, false)
		if spawn_node and spawn_node is Marker2D:
			global_position = spawn_node.global_position
			# In log để debug
			print("Player spawned at: ", Global.player_spawn_name, " position: ", spawn_node.global_position)
		else:
			print("Warning: Spawn point node '", Global.player_spawn_name, "' not found!")
		# Reset lại trạng thái spawn toàn cục
		Global.player_spawn_name = ""

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2.ZERO
	
	# Hỗ trợ cả phím WASD và phím Mũi tên trực tiếp mà không cần cấu hình Input Map
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		input_dir.y += 1
		
	var target_velocity = input_dir.normalized() * speed
	
	# Nội suy (lerp) vận tốc hiện tại tới vận tốc mục tiêu để tăng/giảm tốc mượt mà
	velocity = velocity.lerp(target_velocity, acceleration)
	
	move_and_slide()
