extends Node2D

@export var G:Gameplay

var pt_0:Vector2
var pt_1:Vector2
var rect:Rect2
var size_vec:Vector2
var offset_vec:Vector2

var rows:int
var cols:int

var width:float = 3.0
var Col_Grid:Color = Color.AQUA
var Col_Rect:Color = Color.CRIMSON

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pt_0 = G.ZERO_vec
	pt_1 = G.ZERO_vec
	
	size_vec = Vector2(G.velocity, G.velocity)
	
	rows = G.rows + 1
	cols = G.cols + 1
	
	offset_vec = G.ZERO_vec
	offset_vec.x -= G.velocity * 2.0
	offset_vec.y = G.velocity * 5.0
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# flag
	if G.debug_flag == false: return
	
	# draw grid
	
	pt_0.x = G.L
	pt_0.y = G.T
	pt_1.x = G.R
	
	for yi in rows:
		pt_1.y = pt_0.y
		draw_line(pt_0,pt_1, Col_Grid, width)
		pt_0.y += G.velocity
	
	pt_1.y = G.T
	pt_0.y -= G.velocity
	
	for xi in cols:
		pt_1.x = pt_0.x
		draw_line(pt_0,pt_1, Col_Grid, width)
		pt_0.x += G.velocity
	
	# draw player rect
	pt_0 = G.Player.position# + offset_vec
	
	rect = Rect2(pt_0, size_vec)
	draw_rect(rect, Col_Rect, false, width)
