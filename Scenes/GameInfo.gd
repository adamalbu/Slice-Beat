extends Node

@export_group("Level Info")
@export var song_player : AudioStreamPlayer
@export var level_info_file : JSON
@export_enum("Play", "Beat Show") var mode : int

@export_group("Arrow Prefab")
@export var raycast_in : RayCast2D
@export var raycast_out : RayCast2D

var recorded_level_info = {"beats": {}}
var last_recoreded_pos = Vector2(-99999, -99999)
var last_recorded_playback_pos : float
var level_info : Dictionary
# Called when the node enters the scene tree for the first time.
func _ready():
	level_info = level_info_file.data
	if mode == 0:
		var arrow_prefab
		var beat_info : Dictionary
		for beat in level_info["beats"]:
			beat_info = level_info["beats"][beat]
			arrow_prefab = preload("res://Prefabs/arrow.tscn").instantiate()
			arrow_prefab.time_offset = beat
			arrow_prefab.init_pos = Vector2(beat_info["pos"][0], beat_info["pos"][1])
			if "rot" in beat_info.keys():
				arrow_prefab.init_rot = deg_to_rad(beat_info["rot"])
			else:
				arrow_prefab.init_rot = 0
			arrow_prefab.hit_raycast_in = raycast_in
			arrow_prefab.hit_raycast_out = raycast_out
			add_child(arrow_prefab)
	song_player.play()

func _input(event):
	if mode == 1:
		var beat_info
		var playback_pos
		if event is InputEventMouseButton and event.button_mask == 1:
			playback_pos = song_player.get_playback_position()
			beat_info = {playback_pos: {}}
			beat_info[playback_pos]["pos"] = [event.position.x, event.position.y]
			recorded_level_info["beats"][str(playback_pos)] = beat_info[playback_pos]
			print(recorded_level_info)
			print(beat_info[playback_pos])
			
			if last_recoreded_pos != Vector2(-99999, -99999):
				var prev_rot = rad_to_deg(last_recoreded_pos.angle_to_point(event.position))
				recorded_level_info["beats"][str(last_recorded_playback_pos)]["rot"] = prev_rot
			
			last_recoreded_pos = event.position
			last_recorded_playback_pos = playback_pos
		if song_player.get_playback_position() == 0:
			print(recorded_level_info)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
