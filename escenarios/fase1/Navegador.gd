extends Spatial

export var 	casillas_suelo=[1,2]
var a_star

var MAX=1000

var cuadricula

# Called when the node enters the scene tree for the first time.
func _ready():
	cuadricula=get_node("../GridMap")
	a_star= AStar.new()
	crear_malla(a_star,cuadricula)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func calcular_ruta(origen,destino):
	var casilla_final=cuadricula.world_to_map(destino)
	var casilla_inicial=cuadricula.world_to_map(origen)
		# print(str(casilla_inicial)+" -> "+str(casilla_final))
		
	var ruta=a_star.get_point_path(vector_to_id(casilla_inicial),
		vector_to_id(casilla_final))
		
	var pasos=[]
	pasos.resize(ruta.size())
		
	var i=0
	for paso in ruta:
		pasos[i]=cuadricula.map_to_world(paso.x,paso.y,paso.z)
		i=i+1;
	
	print("Ruta: "+str(ruta))
	print("Pasos: "+str(pasos))
	
	return pasos
		
func vector_to_id(vector):
	return (vector.x+MAX/2)+(vector.z+MAX/2)*MAX


func crear_malla(_a_star, _cuadricula):
	
	for celda in _cuadricula.get_used_cells():		
		# Introducimos solo las casillas que son travesables
		if casillas_suelo.has(_cuadricula.get_cell_item(celda.x,celda.y,celda.z)):
			var id=vector_to_id(celda)
			_a_star.add_point(id,celda)
		
	for punto in _a_star.get_points():
		var celda=_a_star.get_point_position(punto)
		var id=vector_to_id(celda)
		
		# miramos norte:
		if casillas_suelo.has(_cuadricula.get_cell_item(celda.x,celda.y,celda.z-1)):
			var id2=vector_to_id(Vector3(celda.x,0,celda.z-1))
			_a_star.connect_points(id,id2)
			
		# miramos sur:
		if casillas_suelo.has(_cuadricula.get_cell_item(celda.x,celda.y,celda.z+1)):
			var id2=vector_to_id(Vector3(celda.x,0,celda.z+1))
			_a_star.connect_points(id,id2)
			
		# miramos este:
		if casillas_suelo.has(_cuadricula.get_cell_item(celda.x+1,celda.y,celda.z)):
			var id2=vector_to_id(Vector3(celda.x+1,0,celda.z))
			_a_star.connect_points(id,id2)
		
		# miramos oeste:
		if casillas_suelo.has(_cuadricula.get_cell_item(celda.x-1,celda.y,celda.z)):
			var id2=vector_to_id(Vector3(celda.x-1,0,celda.z))
			_a_star.connect_points(id,id2)

			

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
