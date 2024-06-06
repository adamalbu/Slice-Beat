extends Node

@export var debug_circle_in : Sprite2D
@export var debug_circle_out : Sprite2D
@export var debug_line_in : Line2D
@export var debug_line_out : Line2D
@export var hit_raycast_in : RayCast2D
@export var hit_raycast_out : RayCast2D
@export var collider : CollisionShape2D
var last_mouse_pos : Vector2
var current_mouse_pos : Vector2

# Called when the node enters the scene tree for the first time.
# func _ready():
	# debug_circle = "metadata/debug_circle"

func draw_debug_circle(mouse_pos):
	current_mouse_pos = mouse_pos
	debug_circle_out.set_position(mouse_pos)
	debug_circle_in.set_position(mouse_pos)

func _input(event):
	if event is InputEventMouseMotion:
		draw_debug_circle(event.position)
		
func _physics_process(delta):
	#var space_state = get_viewport().get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var start_pos_out = current_mouse_pos
	var offset_out = last_mouse_pos - current_mouse_pos
	var start_pos_in = last_mouse_pos
	#var offset_in = Vector2(0,0)
	var offset_in = current_mouse_pos - last_mouse_pos
	#var query = PhysicsRayQueryParameters2D.create(current_mouse_pos, last_mouse_pos)
	#var query = hit_raycast.
	debug_line_out.points[0] = start_pos_out
	debug_line_out.points[1] = current_mouse_pos + offset_out
	debug_line_in.points[0] = start_pos_in
	debug_line_in.points[1] = current_mouse_pos + offset_in
	
	hit_raycast_out.position = start_pos_out
	hit_raycast_out.target_position = offset_out
	hit_raycast_in.position = start_pos_in
	hit_raycast_in.target_position = offset_in
	
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
	
	#print(hit_raycast.is_colliding())
	
	
	last_mouse_pos = current_mouse_pos
	
	#var result = space_state.intersect_ray(query)
	#print(result)
	
func slice(enter_pos, exit_pos):
	var adjacent = abs(enter_pos.x - exit_pos.x)
	var opposite = abs(enter_pos.y - exit_pos.y)
	var angle = rad_to_deg(atan(opposite/adjacent))
	
	var midpoint = (enter_pos + exit_pos)/2
	var tri_corner = Vector2(self.position.x, midpoint.y)
	var len1 = abs(midpoint.x - tri_corner.x)
	var len2 = abs(self.position.y - tri_corner.y)
	var absDist = sqrt(len1**2 + len2**2)
	var dist = absDist/(collider.shape.radius)
	
	var timing = 25 #TODO: implement timing
	
	var features_score = {}
	features_score["dist"] = -13.6*(1+0.0107)**dist+38.6
	features_score["timing"] = -10*(1+0.033)**timing+50
	features_score["angle"] = -angle*0.6+35
	
	var score = features_score["dist"] + features_score["timing"] + features_score["angle"]
	score = round(score/10)*10
	print(score)

func mouse_enter():
	pass
	#print("Enter")
	#var new_debug_circle = debug_circle.duplicate()
	#$"..".add_child(new_debug_circle)
	
func mouse_exit():
	pass
	#print("Exit")
