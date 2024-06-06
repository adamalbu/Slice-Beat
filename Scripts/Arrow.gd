extends Node

@export var collider : CollisionShape2D
@export var timing_indicator : Sprite2D
@export var debug_circle_in : Sprite2D
@export var debug_circle_out : Sprite2D
@export var debug_line_in : Line2D
@export var debug_line_out : Line2D
@export var hit_raycast_in : RayCast2D
@export var hit_raycast_out : RayCast2D
var last_mouse_pos : Vector2
var current_mouse_pos : Vector2

var time_left = 100
var timing_finished = false

var sliced = false

func _process(delta):
	if !timing_finished:
		update_timing_indicator(delta)
	
func update_timing_indicator(delta: float):
	time_left -= 100*delta
	timing_indicator.modulate.a = (-time_left+100)/100
	timing_indicator.scale = Vector2(time_left/200+0.5, time_left/200+0.5)
	if time_left < 0 and sliced:
		timing_indicator.queue_free()
		timing_finished = true
	if time_left < 0:
		timing_indicator.modulate.a = 0

func draw_debug_circle(mouse_pos):
	current_mouse_pos = mouse_pos
	debug_circle_out.set_position(mouse_pos)
	debug_circle_in.set_position(mouse_pos)

func _input(event):
	if event is InputEventMouseMotion:
		draw_debug_circle(event.position)
		
func _physics_process(delta):
	# Ray positions
	var start_pos_out = current_mouse_pos
	var offset_out = last_mouse_pos - current_mouse_pos
	var start_pos_in = last_mouse_pos
	var offset_in = current_mouse_pos - last_mouse_pos
	
	# Show rays
	debug_line_out.points[0] = start_pos_out
	debug_line_out.points[1] = current_mouse_pos + offset_out
	debug_line_in.points[0] = start_pos_in
	debug_line_in.points[1] = current_mouse_pos + offset_in
	
	# Raycasts
	hit_raycast_out.position = start_pos_out
	hit_raycast_out.target_position = offset_out
	hit_raycast_in.position = start_pos_in
	hit_raycast_in.target_position = offset_in
	
	# Check hit
	var new_debug_circle
	
	if hit_raycast_in.is_colliding():
		new_debug_circle = debug_circle_in.duplicate()
		$"..".add_child(new_debug_circle)
		new_debug_circle.position = hit_raycast_in.get_collision_point()
		
	if hit_raycast_out.is_colliding():
		new_debug_circle = debug_circle_out.duplicate()
		$"..".add_child(new_debug_circle)
		new_debug_circle.position = hit_raycast_out.get_collision_point()
		slice(hit_raycast_in.get_collision_point(), hit_raycast_out.get_collision_point())	
	
	last_mouse_pos = current_mouse_pos
	
func slice(enter_pos, exit_pos):
	sliced = true
	
	# CALCULATE SCORES
	# calculate angle
	var adjacent = abs(enter_pos.x - exit_pos.x)
	var opposite = abs(enter_pos.y - exit_pos.y)
	var angle = rad_to_deg(atan(opposite/adjacent))
	
	# calculate distance
	var midpoint = (enter_pos + exit_pos)/2
	var tri_corner = Vector2(self.position.x, midpoint.y)
	var len1 = abs(midpoint.x - tri_corner.x)
	var len2 = abs(self.position.y - tri_corner.y)
	var absDist = sqrt(len1**2 + len2**2)
	var dist = absDist/(collider.shape.radius)
	
	var timing = abs(time_left)
	
	# Calculate overall score
	var features_score = {}
	features_score["dist"] = -13.6*(1+0.0107)**dist+38.6
	features_score["timing"] = -10*(1+0.033)**timing+50
	features_score["angle"] = -angle*0.6+35
	
	var score = features_score["dist"] + features_score["timing"] + features_score["angle"]
	score = round(score/10)*10
	
	print("SLICE")
	print(score)
	print(time_left)
