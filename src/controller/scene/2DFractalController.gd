tool
extends Node2D

const ZOOM_INCREMENT = 0.1
const ZOOM_SENSITIVITY = 20
const ZOOM_SPEED = 0.04

export(float) var fractal_scale = -1.0 setget set_fractal_scale
export(int) var max_iterations = 500 setget set_max_iterations

onready var display = $Display

var drag_position = Vector2.ZERO
var last_drag_distance = 0
var is_zooming = false
var is_dragging = false
var events = {}

func set_fractal_scale(new_scale: float):
	render_fractal_scale(new_scale)
	fractal_scale = new_scale

func set_max_iterations(new_iter: int):
	render_fractal_iter(new_iter)
	max_iterations = new_iter

func render_fractal_scale(scale):
	if display != null:
		display.material.set_shader_param('scale', scale)

func render_fractal_position(position):
	if display != null:
		display.material.set_shader_param('position', position)

func render_fractal_iter(iter):
	if display != null:
		display.material.set_shader_param('max_iter', iter)

func drag_fractal(drag: Vector2):
	drag_position -= drag
	render_fractal_position(drag_position)

func zoom_in():
	set_fractal_scale(fractal_scale+ZOOM_INCREMENT)

func zoom_out():
	set_fractal_scale(fractal_scale-ZOOM_INCREMENT)

func _unhandled_input(event):
	# touch-screens
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)
	if event is InputEventScreenDrag:
		is_dragging = events.size() == 1
		is_zooming = events.size() == 2
		events[event.index] = event
		if events.size() == 1:
			drag_fractal(event.relative/exp(fractal_scale)*Vector2(2,-2))
			render_fractal_position(drag_position)
		elif events.size() == 2:
			var drag_distance = events[0].position.distance_to(events[1].position)
			if abs(drag_distance - last_drag_distance) > ZOOM_SENSITIVITY:
				var new_scale = (1 + ZOOM_SPEED) if drag_distance > last_drag_distance else (1 - ZOOM_SPEED)
				new_scale = clamp(log(exp(fractal_scale) * new_scale), -1, 100)
				set_fractal_scale(new_scale)
				last_drag_distance = drag_distance
	# keyboard and mouse
	if event is InputEventMouseButton:
		is_dragging = event.pressed
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_in()
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_out()
	if event is InputEventMouseMotion:
		if is_dragging:
			drag_fractal(event.relative/exp(fractal_scale)*Vector2(2,-2))


func _on_MaxIterations_value_changed(value):
	set_max_iterations(int(value))
