extends KinematicBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#signal andar()
#signal rotar_derecha()
#signal rotar_izquierda()
#signal esperar()


const RAY_LENGTH=1000
export var MARGENX=0.5
export var MARGENZ=0.5

export var usar_teclado=false

signal fin_de_movimiento()

const Repetidor = preload("res://objetos/onda/Onda.tscn")
const RepetidorWalkie = preload("res://objetos/walkie_talkie/WalkieOnda.tscn")

onready var camara=get_node("../Camera")

#export var velocidad_andar=100
export var andar_temporizador=1
export var parar_temporizador=1

export var celeridad=40
export var celeridad_rotar=0.075
onready var navegador=get_node("../Navegador")

var direccion=Vector3(0,0,1)

var en_ruta=0
var ruta

enum ESTADOS {parado,andando,muriendo,bailando,rotando_derecha,rotando_izquierda}
const INTER_CLICK_TIME=500

var estado=ESTADOS.parado
var hay_que_poner_repetidor=false

var ultima_vez_presionado=0

var direccion_ruta=Vector3(0,0,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_node("../HUD/GridContainer/bAndar").connect("andar",self,"andar")
	pass # Replace with function body.

func esperar():
	estado=ESTADOS.parado
	$Temporizador.start(parar_temporizador)
	
func rotar_derecha():
	estado=ESTADOS.rotando_derecha
	$AnimationPlayer.play("rotar-derecha")

func rotar_izquierda():
	estado=ESTADOS.rotando_izquierda
	$AnimationPlayer.play("rotar-izquierda")

func andar():
	$Temporizador.start(andar_temporizador)
	estado=ESTADOS.andando
	$AnimationPlayer.play("andando")
	
func andar_test():
	$Temporizador.start(andar_temporizador)
	estado=ESTADOS.andando
	$AnimationPlayer.play("andando")
	$AnimationPlayer.play("Puerta1")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var direccion=Vector3(0,0,1)
	
	if usar_teclado:
		if Input.is_action_pressed("izquierda"):
			rotate_y(celeridad_rotar)
		if Input.is_action_pressed("derecha"):
			rotate_y(-celeridad_rotar)
		
		if Input.is_action_pressed("adelante"):	
			#direccion=get_global_transform().basis.z.normalized()
			#direccion.y=1
			#var mover=move_and_slide(velocidad_andar*direccion*delta*celeridad)			
			
			var facing = global_transform.basis.z
			facing=get_global_transform().basis.z.normalized()
			facing.y=-1 # La gravedad...
			move_and_slide(facing*delta*celeridad)
		
			$AnimationPlayer.play("andando")
		else:
			$AnimationPlayer.play("default")
	
	if Input.is_action_just_pressed("accion"):
		var hora=OS.get_ticks_msec()
		if hora-ultima_vez_presionado<INTER_CLICK_TIME:
			hay_que_poner_repetidor=true
		else: # queremos que se mueva:
			ruta=calcular_ruta()
			ruta.remove(0)
			$AnimationPlayer.play("andando")
			iniciar_ruta(ruta)
			
			# mostrar_ruta(ruta)
			
		ultima_vez_presionado=hora
	
	if en_ruta:
		
		if ruta!=null and ruta.size()>0:
			
			if en_casilla(ruta[0]):
				#print("Llegado a "+str(ruta[0]))
				ruta.remove(0)
			
			if ruta.size()>0:
				var d1=translation
				var d2=ruta[0]
				d2.y=d1.y
				look_at(d2,Vector3(0,1,0))
				rotate_y(PI) # Tweak chungo... ¿El muñeco está al revés?
				move_and_slide((d2-d1).normalized()*delta*celeridad)
		else:
			$AnimationPlayer.play("default")
			if hay_que_poner_repetidor:
				hay_que_poner_repetidor=false
				poner_repetidor(translation)
	
#	if en_ruta:
#		if ruta.size()==1 and en_casilla(ruta[1]):
#			print(ruta)
#			if ruta.size()<2:
#				print("Ha llegado")
#				en_ruta=false
#				ruta.queue_free()
#			else:
#				ruta.remove(0)
#				if (ruta.size()>1):
#					iniciar_ruta(ruta)
#
#				else:
#					print("Error en la ruta")
#		else:
#			var mirar=ruta[1]
#			mirar.y=translation.y
#			look_at(mirar,Vector3(0,1,0))
#			move_and_slide(direccion_ruta*delta*celeridad)
			
			
func en_casilla(poscion):
	var enc=false
	# print("diff: "+str(abs(translation.x-poscion.x))+", "+str(abs(translation.z-poscion.z)))
	if abs(translation.x-poscion.x)<MARGENX and abs(translation.z-poscion.z)<MARGENZ:
		enc=true
	return enc
	
	
func iniciar_ruta(ruta_):
	en_ruta=true
	# direccion_ruta=calcular_direccion(ruta)
	#print(ruta[0])
	### $Timer.start()
	
	
func calcular_direccion(ruta_):
	return (ruta[1]-ruta[0]).normalized()
			
func calcular_ruta():
	var objeto=get_object_under_mouse()
	if objeto.size() > 0:
		ruta=navegador.calcular_ruta(translation,objeto.position)
	return ruta
			
func poner_repetidor(posicion):
	var repetidor=RepetidorWalkie.instance()
	repetidor.global_transform = global_transform
	repetidor.scale_object_local(Vector3(1,1,1))
	get_node("..").add_child(repetidor)

func parar():
	estado=ESTADOS.parado
	$AnimationPlayer.play("default")

func _on_Temporizador_timeout():
	$Temporizador.stop()
		
	match estado:
		ESTADOS.andando, ESTADOS.parado, ESTADOS.rotando_derecha,	ESTADOS.rotando_izquierda:
			parar()
			emit_signal("fin_de_movimiento")
		
			
			
func _on_animation_finished(anim_name):
	
	match anim_name:
		"rotar-derecha":
			
			rotate(Vector3.UP,-PI/2)
			print("Fin rotar derecha")
			print("Rotado a derecha?")
			emit_signal("fin_de_movimiento")

			
		"rotar-izquierda":
			rotate(Vector3.UP,PI/2)
			print("Fin rotar izquierda")
			print("Rotado a izquierda?")
			emit_signal("fin_de_movimiento")
			
# https://godotengine.org/qa/54704/simple-3d-building-system-with-gridmap
func get_object_under_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = camara.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camara.project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	return selection
	
func get_object_under_player(posicion):
	var ray_from = posicion
	var ray_to = ray_from + Vector3.DOWN * RAY_LENGTH
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	return selection

func mostrar_ruta(ruta):
	for paso in ruta:
		paso.y=1
		print(paso)
		poner_repetidor(paso)


func _on_Timer_timeout():
	
	# Error:
	$Timer.stop()
	
	if ruta!=null and ruta.size()>0:
		#Miremos al objetivo:
		translation=ruta[0]
			
		ruta.remove(0)
			
		$Timer.start()
		
	else:
		$Timer.stop()
		en_ruta=false
