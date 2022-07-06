tool
extends MeshInstance

export(Gradient) var terrain_gradient = Gradient.new()
export(int) var size = 30 setget set_size
export(int) var height_limit = 5 setget set_height_limit
export(int) var height_multiplier = 10 setget set_height_multiplier
export(bool) var show_vertices = false setget set_show_vertices
export(bool) var is_island = false setget set_is_island

onready var tree_scene = preload("res://trees/PalmTree_1.tscn")

func _ready():
	randomize();
	_generate()

func _clear() -> void:
	for child in $VerticesContainer.get_children():
		$VerticesContainer.remove_child(child)
	
	for child in $TreesContainer.get_children():
		$TreesContainer.remove_child(child)

func _update() -> void :
	_clear();
	_generate();

func _generate() -> void:
	var vertices_data = _get_vertices_data();
	
	if show_vertices:
		draw_vertices(vertices_data.vertices)
	
	_generate_mesh(vertices_data)
	_add_trees(vertices_data.vertices)


func _get_vertices_data() -> Dictionary:
	var vectices = PoolVector3Array();
	var normals = PoolVector3Array();
	var colors = Array();
	var uv = Array();
	
	var noise = _get_noise();
	var center_offset = Vector3(0, 0, 0);
	
	for z in size:
		for x in size:
			var noise_value = noise.get_noise_2d(x, z) 
			
			var distance_x = float(x) - float(size) * 0.5;
			var distance_y = float(z) - float(size) * 0.5;
			var distance = sqrt(distance_x*distance_x + distance_y*distance_y);
			
			var max_width = size * 0.3;
			var delta = distance / max_width;
			var gradient = delta * delta;
			
			noise_value = abs(noise_value) * height_multiplier + 2;
			
			
			if (is_island):
				noise_value *= max(0.0, 2.0 - gradient);
			
			if noise_value > height_limit:
				noise_value = height_limit
			
			var position = Vector3(x + center_offset.x, noise_value, z + center_offset.z)
			vectices.append(position)
			
			var aa = lerp(0.0, 1.0, float(noise_value) / float(height_multiplier + 2))  
			
			colors.append(terrain_gradient.interpolate(aa));
			uv.append(Vector2(float(x)/size, float(z)/size))
	
	return {
		"vertices": vectices,
		"uv": uv,
		"colors": colors
	}

func _add_trees(vertices: PoolVector3Array) -> void:
	for vertex in vertices:
		if vertex.y >= height_multiplier -3  && rand_range(0, 1) < 0.01:
			var tree_instance: MeshInstance = tree_scene.instance();
			tree_instance.translation = vertex
			tree_instance.translation.y -= 0.5
			tree_instance.rotate_y(rand_range(0, 360))
			$TreesContainer.add_child(tree_instance)

func _generate_mesh(vertices_data: Dictionary) -> void:
	var arrays = []
	
	arrays.resize(Mesh.ARRAY_MAX)
	
	var indices = PoolIntArray();
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.add_smooth_group(true)
	
	for i in vertices_data.vertices.size():
		st.add_uv(vertices_data.uv[i])
		st.add_color(vertices_data.colors[i])
		st.add_vertex(vertices_data.vertices[i])

	
	for z in size-1:
		var x_offset = size * z;
		var z_offset = size * (z + 1)
		for x in size-1:
			st.add_index(x + x_offset)
			st.add_index(x + x_offset + 1)
			st.add_index(z_offset + x)
			
			st.add_index(x + x_offset + 1)
			st.add_index(z_offset + x + 1)
			st.add_index(z_offset + x)
	
	st.generate_normals();
	
	mesh = st.commit()

func _get_noise() -> OpenSimplexNoise:
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 50.0
	noise.persistence = 0.8
	
	return noise;


func draw_vertices(vertices: PoolVector3Array) -> void:
	for vertex in vertices:
		var shape = CSGSphere.new()
		shape.radius = 0.1
		shape.translation = vertex
		$VerticesContainer.add_child(shape)


# GETTERS & SETTERS 

func set_is_island(new_is_island):
	is_island = new_is_island
	if Engine.editor_hint:
		_update();
		
func set_height_limit(new_height_limit):
	height_limit = new_height_limit
	if Engine.editor_hint:
		_update();
		
func set_height_multiplier(new_height_multiplier):
	height_multiplier = new_height_multiplier
	if Engine.editor_hint:
		_update();

func set_size(new_size):
	size = new_size
	if Engine.editor_hint:
		_update();

func set_show_vertices(new_show_vertices):
	show_vertices = new_show_vertices;
	if Engine.editor_hint:
		_update();




