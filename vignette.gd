## Vignette Overlay — màn hình tối dần ở các cạnh
## Tạo cảm giác ngột ngạt, áp lực tâm lý không cần jumpscare
## Gọi: Vignette.show_vignette(intensity) / Vignette.hide_vignette()
extends Node

var canvas_layer: CanvasLayer
var vignette_rect: ColorRect
var _tween: Tween = null

func _ready() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10 # Hiển thị trên game nhưng dưới Narrative
	add_child(canvas_layer)
	
	vignette_rect = ColorRect.new()
	canvas_layer.add_child(vignette_rect)
	
	# Phủ toàn màn hình
	vignette_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Màu đen trong suốt ban đầu
	vignette_rect.color = Color(0, 0, 0, 0)
	
	# Shader đơn giản tạo vignette hình tròn từ tâm ra
	var shader_code = """
shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float vignette = smoothstep(0.35, 0.75, dist * (0.8 + intensity * 0.8));
	COLOR = vec4(0.0, 0.0, 0.0, vignette * intensity);
}
"""
	var shader = Shader.new()
	shader.code = shader_code
	var shader_mat = ShaderMaterial.new()
	shader_mat.shader = shader
	vignette_rect.material = shader_mat
	
	# Ẩn mặc định
	vignette_rect.hide()
	print("[Vignette] Overlay ready")

## Hiển thị vignette với cường độ mục tiêu (0.0 = ẩn, 1.0 = tối cạnh rõ rệt)
func show_vignette(target_intensity: float = 0.6, duration: float = 1.5) -> void:
	vignette_rect.show()
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_intensity, _get_intensity(), target_intensity, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	print("[Vignette] Showing at intensity: ", target_intensity)

## Ẩn vignette từ từ
func hide_vignette(duration: float = 1.5) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_intensity, _get_intensity(), 0.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await _tween.finished
	vignette_rect.hide()

func _set_intensity(value: float) -> void:
	if vignette_rect and vignette_rect.material:
		(vignette_rect.material as ShaderMaterial).set_shader_parameter("intensity", value)

func _get_intensity() -> float:
	if vignette_rect and vignette_rect.material:
		var val = (vignette_rect.material as ShaderMaterial).get_shader_parameter("intensity")
		if val == null:
			return 0.0
		return float(val)
	return 0.0
