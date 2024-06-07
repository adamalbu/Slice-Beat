extends Node

@export_group("Child Components")
@export var collider : CollisionShape2D
@export var arrow_sprite : Sprite2D
@export var timing_indicator : Sprite2D
@export var timing_hit : Sprite2D
@export var time_offset : float
@export var score_sprite : Sprite2D

@export_group("External Components")
@export var hit_raycast_in : RayCast2D
@export var hit_raycast_out : RayCast2D

@export_group("Other")
@export var init_pos : Vector2
@export var init_rot : float

var last_mouse_pos : Vector2
var current_mouse_pos : Vector2

var time_left = 100
var timing_finished = false

var sliceable = false
var sliced = false
var after_slice_time = 100

func _ready():
	self.position = init_pos
	self.arrow_sprite.rotation = init_rot
	time_offset -= 1
	time_offset *= 100
	timing_indicator.modulate.a = 0
	if time_offset < 0:
		time_left = -time_offset

func _process(delta):
	if !timing_finished:
		update_timing_indicator(delta)
	if sliced:
		update_score_sprite(delta)
	
func update_timing_indicator(delta: float):
	if time_offset <= 0:
		time_left -= 100*delta
		timing_indicator.modulate.a = (-time_left+100)/100
		timing_indicator.scale = Vector2(time_left/200+0.5, time_left/200+0.5)
		if time_left < 0 and sliced:
			timing_indicator.queue_free()
			timing_finished = true
		if time_left < 0:
			timing_indicator.modulate.a = 0
	else:
		time_offset -= 100*delta
		if time_offset < 100:
			self.modulate.a = (-time_offset + 100)/100
			self.sliceable = true
		else:
			self.modulate.a = 0

func update_mouse_pos(mouse_pos):
	current_mouse_pos = mouse_pos

func _input(event):
	if event is InputEventMouseMotion:
		update_mouse_pos(event.position)
		
func update_score_sprite(delta):
	if sliced:
		var score_col = Color(score_sprite.modulate.r, score_sprite.modulate.g, score_sprite.modulate.b, 0)
		get_tree().create_tween().tween_property(score_sprite, "offset", Vector2(0, -100), 1)
		var tween = get_tree().create_tween()
		tween.tween_property(score_sprite, "modulate", score_col, 1)
		tween.tween_callback(self.queue_free)
		var arrow_col = Color(arrow_sprite.modulate.r, arrow_sprite.modulate.g, arrow_sprite.modulate.b, 0)
		var hit_col = Color(timing_hit.modulate.r, timing_hit.modulate.g, timing_hit.modulate.b, 0)
		get_tree().create_tween().tween_property(arrow_sprite, "modulate", arrow_col, 0.2)
		get_tree().create_tween().tween_property(timing_hit, "modulate", hit_col, 0.2)
		
func _physics_process(delta):
	# Ray positions
	var start_pos_out = current_mouse_pos
	var offset_out = last_mouse_pos - current_mouse_pos
	var start_pos_in = last_mouse_pos
	var offset_in = current_mouse_pos - last_mouse_pos
	
	# Raycasts
	hit_raycast_out.position = start_pos_out
	hit_raycast_out.target_position = offset_out
	hit_raycast_in.position = start_pos_in
	hit_raycast_in.target_position = offset_in
	
	#Check hit
		
	if hit_raycast_out.is_colliding() and hit_raycast_out.get_collider() == self:
		slice(hit_raycast_in.get_collision_point(), hit_raycast_out.get_collision_point())	
	
	last_mouse_pos = current_mouse_pos
	
func slice(enter_pos, exit_pos):
	if !sliceable:
		return
	sliced = true
	
	# CALCULATE SCORES
	# calculate angle
	var adjacent = abs(enter_pos.x - exit_pos.x)
	var opposite = abs(enter_pos.y - exit_pos.y)
	var angle = rad_to_deg(atan(opposite/adjacent) - self.arrow_sprite.rotation)
	
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
	
	if score > 100:
		score = 100
	elif score < 0:
		score = 0
		
	score_sprite.texture = load("res://Assets/numbers/%s.png" % score)
	
	print("SLICE")
	print(score)
	print(time_left)
