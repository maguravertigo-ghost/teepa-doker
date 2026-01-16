class_name Player_class
extends Node2D

@export var G:Gameplay

@export var Body:Node2D
@export var Move_BOX:Node2D

@export var Group:Node2D
@export var Hand_L:Node2D
@export var Hand_R:Node2D

var Left_pos:Vector2
var Right_pos:Vector2

var FACE_DIR:int

var can_walk:bool
var EMPTY_cell_vec:Vector2i = Vector2i(-1,-1)
var move_step_vec:Vector2
var move_box:bool
var next_BOX_cell:Vector2i
var BOX_base_pos:Vector2 = Vector2(0.0, -32.0)

@export var Weapoon:TextureRect

@export var AnimPlayer:AnimationPlayer

@onready var Chest_EVT_src:PackedScene = preload("res://chest_event.tscn")

var Old_position:Vector2

var face_dir_right:bool = true

var cell_index:Vector2i

var power:int = 0
var MAX_power:int = 12

var Win_STACK:Array = []
var Chest_STACK:Array = []

var placeholders_count:int

var CELLS:Dictionary = {
	&"EMPTY":-1,
	&"WALL":9,
	&"BOX":60,
	&"PLACEHOLDER":77,
	&"CHEST_SPOT":888,
	&"CHEST_FRAME_0":80,
}
var ITEMS:Dictionary = {
	&"BOX":Vector2i(3, 5),
	&"CHEST":Vector2i(85, 119),
	&"HAMMER":Vector2i(153, 153)
}
var ALPHA_WALL:Vector2i = Vector2i(9,18) # atlas coord = invisible wall

enum { IDLE, WALK, SWING, SWING_AFTER }
var state:int = IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	define_BOX_Spots()
	
	AnimPlayer.animation_finished.connect(Anim_is_finished)
	
	Left_pos = Hand_L.position
	Right_pos = Hand_R.position
	
	FACE_DIR = 1
	
	Move_BOX.visible = false
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# debug
	G.Power.text = "pow : " + str(power)
	
	# STATE MACHINE
	match state:
		IDLE:
			# transition to Swing # action
			if Input.is_action_pressed("action") == true:
				#prints("action")
				# if has weapoon
				state = SWING
				
				Play_Animation("Swing")
			else:
				# check movement
				if G.Input_vec == G.ZERO_vec:
					if power > G.MIN:
						power = G.MIN
				else:
					if power == G.MIN:
						can_walk = false
						move_box = false
						prints("if power == G.MIN: : ")
						Old_position = position
						
						var step_vec:Vector2 = G.Input_vec * G.velocity
						
						position += step_vec
						var next_pos:Vector2i = get_cell_ind_from_vec_pos(position as Vector2i)
						prints("1. > next_pos : ",next_pos)
						if G.TL.get_cell_atlas_coords(next_pos) == EMPTY_cell_vec:
							can_walk = true
						else:
							# if cell is wall
							var cell_value:int
							var next_step_cell:Vector2i = get_cell_ind_from_vec_pos(position)
							var get_data:TileData = G.TL.get_cell_tile_data(next_step_cell)
							if get_data:
								cell_value = get_data.get_custom_data("index")
							else:
								cell_value = CELLS.EMPTY
							
							if cell_value == CELLS.WALL:
								can_walk = false
							else:
								# if it's BOX:
								if cell_value == CELLS.BOX:
									# check if box can move
									var BOX_next_pos:Vector2 = position + step_vec
									var BOX_next_cell_vec:Vector2i = get_cell_ind_from_vec_pos(BOX_next_pos)
									prints("2. > BOX_next_pos : ",BOX_next_pos)
									prints("3. > BOX_next_cell_vec : ",BOX_next_cell_vec)
									if G.TL.get_cell_atlas_coords(BOX_next_cell_vec) == EMPTY_cell_vec:
										# can move BOX
										can_walk = true
										
										# erase BOX current cell
										G.TL.erase_cell(next_step_cell)
										
										# create BOX on next step cell
										next_BOX_cell = next_step_cell + (G.Input_vec as Vector2i)
										
										Move_BOX.visible = true
										Move_BOX.position = BOX_base_pos + G.Input_vec * G.velocity# * Group.scale.x)
										Move_BOX.position.x *= next_BOX_cell.x - next_pos.x
										move_box = true
						
						if can_walk == true:
							change_FACE_DIR(G.Input_vec.x)
							
							position = Old_position
							
							move_step_vec = G.Input_vec * G.scale_factor
							power = G.MIN
							
							Play_Animation("Walk")
							
							state = WALK
						else:
							position = Old_position
							change_FACE_DIR(G.Input_vec.x)
						
						power += G.ONE
					else:
						power += G.ONE
						if power > MAX_power:
							power = G.MIN
							
							Play_Animation("Idle")
							
							state = IDLE
							
		WALK:
			position += move_step_vec
			
			power += G.ONE
			if power > G.cell_W:
				power = G.MIN
				
				Play_Animation("Idle")
				
				if move_box == true:
					G.TL.set_cell(next_BOX_cell, 0, ITEMS.BOX, 0)
					Move_BOX.visible = false
				
				state = IDLE
		SWING_AFTER:
			power += G.ONE
			if power > G.scale_factor:
				power = G.MIN
				
				Play_Animation("Idle")
				
				state = IDLE

func Play_Animation(anim_str_name:String) -> void:
	if AnimPlayer.current_animation != anim_str_name:
		AnimPlayer.play("RESET")
		AnimPlayer.stop()
		AnimPlayer.play(anim_str_name)

func get_cell_ind_from_vec_pos(param_position:Vector2) -> Vector2i:
	param_position -= G.FRAME.position
	param_position /= G.velocity
	#param_position.x -= 2.0
	#param_position.y += 5.0
	
	return (param_position as Vector2i)


func check_win_condition(param_index_vec:Vector2i) -> void:
	# if stack is empty
	prints("- check_win_condition -")
	
	var prev_index_vec:Vector2i = param_index_vec - (G.Input_vec as Vector2i)

	var prev_cell_data:int = get_T_data(G.TL, prev_index_vec,"index")
	
	if prev_cell_data == CELLS.PLACEHOLDER:
		# erase from array
		Win_STACK.erase(prev_index_vec)
	
	
	var next_index_vec:Vector2i = param_index_vec
	var next_cell_data:int = get_T_data(G.TL, prev_index_vec,"index")
	
	if next_cell_data == CELLS.PLACEHOLDER:
		# add to array
		Win_STACK.push_back(next_index_vec)
	
	if Win_STACK.size() == placeholders_count:
		prints("you win")
		
		G.Win_mssg.visible = true
		
		var new_EVT_link:Chest = Chest_EVT_src.instantiate()
		G.Stage.add_child(new_EVT_link)
		new_EVT_link.cell_index = next_index_vec
		new_EVT_link.position = G.FRAME.position + next_index_vec * G.velocity
	
	prints("Win_STACK [",Win_STACK,"]")


func get_T_data(param_TL:TileMapLayer, param_cell_vec:Vector2i, param_data_name:String) -> int:
	var cell_data_value:int = -1
	var get_data:TileData = param_TL.get_cell_tile_data(param_cell_vec)
	if get_data:
		cell_data_value = get_data.get_custom_data(param_data_name)
	else:
		cell_data_value = CELLS.EMPTY
	
	return cell_data_value

func define_BOX_Spots() -> void:
	# get number of spots - placeholders
	placeholders_count = 0
	Win_STACK.clear()
	
	var get_data:int
	var cell_vec:Vector2i
	
	prints("define_BOX_Spots()")
	for yi:int in G.rows:
		for xi:int in G.cols:
			cell_vec = Vector2i(xi,yi)
			get_data = get_T_data(G.PL, cell_vec, "index")
			
			if get_data == CELLS.PLACEHOLDER:
				prints("get_data == CELLS.PLACEHOLDER : ",cell_vec)
				placeholders_count += 1
				#Win_STACK.push_back(cell_vec)
			else:
				if get_data == CELLS.CHEST_SPOT:
					Chest_STACK.push_back(cell_vec)
					
					G.PL.erase_cell(cell_vec)

func Anim_is_finished(anim_name:String) -> void:
	if anim_name == "Swing":
		AnimPlayer.play("RESET")
		AnimPlayer.stop()
		
		power = G.MIN
		state = SWING_AFTER


func change_FACE_DIR(value:int) -> void:
	if value == 0: return
	
	if value > 0:
		# right
		Hand_L.position = Left_pos
		Hand_R.position = Right_pos
		
		#Body.flip_h = false
		FACE_DIR = 1
		Group.scale.x = 1.0
	else:
		# left
		Hand_R.position = Left_pos
		Hand_L.position = Right_pos
		
		#Body.flip_h = true
		FACE_DIR = -1
		Group.scale.x = -1.0
