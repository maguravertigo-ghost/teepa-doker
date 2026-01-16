class_name Gameplay
extends Node2D

static var link:Gameplay = self

@export var TL:TileMapLayer
@export var PL:TileMapLayer

@export var FRAME:ColorRect
@export var Player:Player_class

@export var Output:Label
@export var Win_mssg:Label
@export var Power:Label

@export var Stage:CanvasLayer

var ZERO_vec:Vector2 = Vector2.ZERO

var MIN:int = 0
var ONE:int = 1

var debug_flag:bool = true

var Input_vec:Vector2

var cell_W:float = 16.0
var scale_factor:float = 4.0

var velocity:float = cell_W * scale_factor

var Old_position:Vector2

var cols:int = 13
var rows:int = 6

var L
var T
var R
var B
var W
var H
var hW
var hH
var cx
var cy

var half:float = 2.0

var pos_string:String = "":
	set(txt_val):
		Output.text = txt_val
		pos_string = txt_val
	get:
		return pos_string


func _ready() -> void:
	#CAM.position = Vector2(576, 324)
	link = self
	
	L = FRAME.position.x
	T = FRAME.position.y
	W = FRAME.size.x
	H = FRAME.size.y
	R = L + W
	B = T + H
	hW = W / half
	hH = H / half
	cx = L + hW
	cy = R + hH
	
	# hide
	Win_mssg.visible = false
	
	
	
func _process(_delta: float) -> void:
	
	Input_vec = get_Input()
	
	
func get_Input() -> Vector2:
	# pause - debug flag
	if Input.is_action_just_pressed("pause") == true:
		debug_flag = !debug_flag
	
	# movement
	Input_vec.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	Input_vec.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	if Input_vec.x != 0:
		if Input_vec.y != 0:
			return ZERO_vec
	
	return Input_vec.normalized()
	
	
	
	
