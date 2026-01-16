class_name Chest
extends Node2D

var G:Gameplay

@export var AnimPlayer_Chest:AnimationPlayer

@export var AnimPlayer_Object:AnimationPlayer

var flag:bool = false

enum { WAIT, BORN, ANIM, DROP_ITEM, DISABLE }
var state:int = WAIT

var cell_index:Vector2i


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	# state machine
	match state:
		BORN:
			# create alpha wall
			G.TL.set_cell(cell_index, 0, G.Player.ALPHA_WALL, 0)
			
			AnimPlayer_Chest.play("Born")
			
			state = WAIT
