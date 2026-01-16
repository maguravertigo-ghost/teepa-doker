extends Node2D
 
@onready var Output:Label = $Label


const TIMER_LIMIT = 2.0
var timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Output = get_node("Label")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer > TIMER_LIMIT:
		timer = 0.0
		Output.text = "FPS: " + str(Engine.get_frames_per_second())
		
