extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var animacion="idle"

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play(animacion)
	$AnimationPlayer.queue("default")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
