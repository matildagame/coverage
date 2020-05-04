extends  KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum ESTADOS {andando,parado,atacando}
var estado=ESTADOS.parado

var navegador
var jugador
var ruta
var en_ruta=false

export var celeridad=50
export var MARGENX=0.1
export var MARGENZ=0.1

var perseguir=false

var ultima_vez_presionado=0

# Called when the node enters the scene tree for the first time.
func _ready():
	navegador=get_node("../Navegador")
	jugador=get_node("../MatildaPlus")	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match estado:
		ESTADOS.andando:
			if $AnimationPlayer.current_animation!="andando":
				$AnimationPlayer.play("andando")
			
			if en_ruta:
				if ruta!=null and ruta.size()>0:
					if en_casilla(ruta[0]):
						print("Llegado a "+str(ruta[0]))
						ruta.remove(0)
						
					if ruta.size()>0:
						var d1=translation
						var d2=ruta[0]
						d2.y=d1.y
						look_at(d2,Vector3(0,1,0))
						#rotate_y(PI) # Tweak chungo... ¿El muñeco está al revés?
						move_and_slide((d2-d1).normalized()*delta*celeridad)
				else:
					$AnimationPlayer.play("parado")
					estado=ESTADOS.parado
					en_ruta=false
				
				
		ESTADOS.parado:
			if $AnimationPlayer.current_animation!="parado":
				$AnimationPlayer.play("parado")
				
			
#			if hora-ultima_vez_presionado>30000:
#				buscar_jugador()
				
		ESTADOS.atacando:
			$AnimationPlayer.play("atacar")

func en_casilla(poscion):
	var enc=false
	# print("diff: "+str(abs(translation.x-poscion.x))+", "+str(abs(translation.z-poscion.z)))
	if abs(translation.x-poscion.x)<MARGENX and abs(translation.z-poscion.z)<MARGENZ:
		enc=true
	return enc

func buscar_jugador():
	var hora=OS.get_ticks_msec()
	ruta=navegador.calcular_ruta(translation,jugador.translation)
	print("Ruta alien3: "+str(ruta))
	
	en_ruta=true
	ultima_vez_presionado=hora
	
	# QUitamos la primera casilla:
	if ruta.size()>1:
		ruta.remove(0)

func _on_detector_radio_area_entered(area):
	buscar_jugador()
	estado=ESTADOS.andando

func _on_detector_radio_body_entered(body):
	#print("----> Entró")
	estado=ESTADOS.atacando

func _on_detector_radio_body_exited(body):
	
	if $AnimationPlayer.current_animation=="atacar":
		perseguir=true	


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="atacar":
		perseguir=false
		if perseguir:
			buscar_jugador()
			estado=ESTADOS.andando
		else:
			estado=ESTADOS.parado			
