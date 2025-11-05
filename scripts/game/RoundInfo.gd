class_name RoundInfo extends RefCounted

var round: int = 0

# start round info
var player_spawn_point: Vector3
var ball_spawn_point: Vector3
var ball_starting_velocity: Vector3
var round_end_distance: int

# post round info
var final_ball_point: Vector3
var final_ball_velocity: Vector3

var previous_round: RoundInfo
