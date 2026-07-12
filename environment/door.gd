extends Area2D

# Xuất ra đường dẫn file của Scene muốn chuyển tới (ví dụ: res://scenes/hallway_test.tscn)
@export_file("*.tscn") var target_scene: String
# Tên của Node Marker2D tại Scene tiếp theo nơi Player sẽ xuất hiện
@export var target_spawn_name: String = ""

func _ready() -> void:
	# Kết nối tín hiệu khi có Body chạm vào Area2D
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Kiểm tra nếu đối tượng va chạm thuộc nhóm "Player"
	if body.is_in_group("Player"):
		if target_scene != "":
			# Thiết lập điểm spawn tiếp theo trong Global autoload
			Global.player_spawn_name = target_spawn_name
			print("Door triggered! Transitioning to: ", target_scene, " (Spawn Marker: ", target_spawn_name, ")")
			
			# Tiến hành chuyển Scene
			get_tree().change_scene_to_file(target_scene)
		else:
			print("Warning: target_scene is empty on door: ", name)
