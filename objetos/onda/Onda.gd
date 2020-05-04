extends Area


signal senial_terminado

const ESTADOS={
	PARADO=0,
	MOVIENDO=1	
}

var estado=ESTADOS.PARADO

enum Tipo {emisor,receptor,repetidor}
export(Tipo) var tipo=Tipo.repetidor

export var tiempo_esperar=5
export var alcance=5
export var velocidad=0.5

var tamanio=0.1
var tiempo=0

# Called when the node enters the scene tree for the first time.
func _ready():
	scale=Vector3(1,1,1)*tamanio

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match estado:
		ESTADOS.PARADO:
			tiempo-=delta
			
			match tipo:
				Tipo.emisor:	
					procesar_emisor()
			
		ESTADOS.MOVIENDO:
			tamanio+=velocidad*delta
			if tamanio>alcance:
				tamanio=0.1
				estado=ESTADOS.PARADO
				tiempo=tiempo_esperar	
			scale=Vector3(1,1,1)*tamanio
		
				
func procesar_emisor():
	if tiempo<0:
		tamanio=0.1
		tiempo=tiempo_esperar			
		estado=ESTADOS.MOVIENDO
		scale=Vector3(1,1,1)*tamanio
			

func _on_Onda_area_entered(area):
	# print ("interferencia")
	match tipo:
		Tipo.repetidor:
			emitir()
			print("Repitiendo")
		Tipo.receptor:
			print("Conseguido")
			emit_signal("senial_terminado")
		
func emitir():
	estado=ESTADOS.MOVIENDO
