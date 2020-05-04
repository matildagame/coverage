extends Area

signal terminado2

enum Tipo {emisor,receptor,repetidor}
export(Tipo) var tipo=Tipo.repetidor

export var tiempo_esperar=5
export var alcance=5
export var velocidad=0.5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var color=""

# Called when the node enters the scene tree for the first time.
func _ready():
	$Onda.tiempo_esperar=tiempo_esperar
	$Onda.alcance=alcance
	$Onda.velocidad=0.5
	$Onda.tipo=tipo


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
