@tool
extends Node3D


# We call them towers, but think of them as verticies
@export var tower_scene: PackedScene
@export var base_center_scene: PackedScene
@export var road_scene: PackedScene
@export var building_scene: PackedScene
@export var sandbag_scene: PackedScene
@export var gate_scene: PackedScene


@export var min_bounds: Vector3 = Vector3(-10, 0, -10)
@export var max_bounds: Vector3 = Vector3(10, 0, 10)
@export var number_of_towers: int = 4
@export var number_of_buildings: int = 4
@export var border_density = 1.0: 
	set(value):
		border_density = value
		add_evenly_spaced_points(perimeter_curve, border_density)


@export var clear_all_button: bool:
	set(val):
		clear_all()
		clear_all_button = false

@export var regenerate_buildings_button: bool:
	set(val):
		if val:
			clear_buildings()
			generate_buildings()
			regenerate_buildings_button = false
			

@export var regenerate_perimeter_towers_button: bool:
	set(val):
		if val:
			clear_towers()
			generate_perimeter_towers()
			regenerate_perimeter_towers_button = false

@export var regenerate_base_center_button: bool:
	set(val):
		if val:
			clear_base_center()
			generate_base_center()
			regenerate_base_center_button = false

@export var regenerate_perimeter_path_button: bool:
	set(val):
		if val:
			clear_perimeter_path()
			generate_path_to_towers()
			regenerate_perimeter_path_button = false

@export var regenerate_sandbag_wall_button: bool:
	set(val):
		if val:
			clear_sandbag_wall()
			generate_sandbag_wall()
			regenerate_sandbag_wall_button = false

@export var regenerate_gate_button: bool:
	set(val):
		if val:
			clear_gate()
			generate_gate()
			regenerate_gate_button = false
			

@export var regenerate_gateway_path_button: bool:
	set(val):
		if val:
			clear_gateway_path()
			generate_path_from_gate_to_base_center()
			regenerate_gateway_path_button = false
			

@export var regenerate_building_paths_to_center_button: bool:
	set(val):
		if val:
			generate_paths_from_buildings_to_base_center()
			regenerate_building_paths_to_center_button = false


var perimeter_path: Path3D
var perimeter_curve: Curve3D
var towers: Array[Node3D] = []
var buildings: Array[Node3D] = []
var base_center: Node3D

var roads: Array[Node3D] = []
var sandbags: Array[Node3D] = []
var gate: Node3D


func clear_all():
	if get_children().size():
		for node in get_children():
			remove_child(node)
			node.queue_free() 	

func generate_buildings():
	if(!towers.size()):
		print("Must generate Towers before buildings")
		return

	print("Generating Buildings")
	# TODO: Need to check if overlapping another points radius
	for i in range(number_of_buildings):
		var building = building_scene.instantiate()
		add_child(building)
		building.owner = get_tree().edited_scene_root
		building.global_position = get_random_position_in_polygon()
		buildings.append(building)

# Checks if a given point is inside the polygon formed by `towers`
func is_point_inside_polygon(point: Vector3, towers: Array[Node3D]) -> bool:
	var xz_point = Vector2(point.x, point.z)
	var tower_points = []
	for tower in towers:
		tower_points.append(Vector2(tower.global_position.x, tower.global_position.z))
	
	var inside = false
	for i in range(tower_points.size()):
		var j = (i + 1) % tower_points.size()
		var a = tower_points[i]
		var b = tower_points[j]
		if ((a.y > xz_point.y) != (b.y > xz_point.y)) and \
				(xz_point.x < (b.x - a.x) * (xz_point.y - a.y) / (b.y - a.y) + a.x):
			inside = not inside
	return inside



func clear_buildings():
	if buildings.size():
		for node in buildings:
			#remove_child(node)
			node.queue_free()
	buildings.clear()


func generate_base_center():
	if (!towers.size()):
		print("Need to have towers to generate Center")
		return
	print("Generating Base Center")
	var centroid = Vector3.ZERO
	for tower in towers:
		centroid += tower.global_position
	centroid /= towers.size()
	base_center = base_center_scene.instantiate()
	add_child(base_center)
	base_center.owner = get_tree().edited_scene_root
	base_center.global_position = centroid
	
func clear_base_center():
	if base_center:
		remove_child(base_center)
		base_center.queue_free()
	base_center = null



func generate_perimeter_towers():
	print("Generating Perimeter Towers")
	# TODO: Need to check if overlapping another points radius
	for i in range(number_of_towers):
		var tower = tower_scene.instantiate()
		add_child(tower)
		tower.owner = get_tree().edited_scene_root
		tower.global_position = get_random_position()
		towers.append(tower)
	towers = sort_towers_clockwise(towers)


func clear_towers():
	if towers.size():
		for node in towers:
			remove_child(node)
			node.queue_free() 	
	towers.clear()


# Function to sort points in clockwise order to form a convex polygon
func sort_towers_clockwise(towers: Array[Node3D]) -> Array[Node3D]:
	var centroid = Vector3.ZERO
	for tower in towers:
		centroid += tower.global_position
	centroid /= towers.size()
	
	# Step 2: Calculate angles from center and store them with the points
	var towers_with_angles = []
	for tower in towers:
		# Vector from center to point
		var rel_point = tower.global_position - centroid
		# Step 3: Calculate angle using atan2(y, x)
		var angle = atan2(rel_point.z, rel_point.x)  # Assuming x and z plane for 3D
		towers_with_angles.append({"tower": tower, "angle": angle})
	
	# Step 4: Sort points by angle in clockwise order
	towers_with_angles.sort_custom(_compare_angles)
	
	# Extract sorted points
	var sorted_towers: Array[Node3D] = []
	for entry in towers_with_angles:
		sorted_towers.append(entry["tower"])
	
	return sorted_towers

# Custom sort function for comparing angles
func _compare_angles(a, b) -> int:
	return a["angle"] < b["angle"] if -1 else 1






func generate_path_to_towers():
	if(!towers.size()):
		print('Need Towers to generate a path')
		return

	print("Generating Path")
	perimeter_path = Path3D.new()
	add_child(perimeter_path)
	perimeter_path.owner = get_tree().edited_scene_root
	perimeter_curve = Curve3D.new()
	
	for tower in towers:
		perimeter_curve.add_point(tower.global_position)
	
	# Close the path by adding the first point again at the end
	perimeter_curve.add_point(perimeter_curve.get_point_position(0))
	
	perimeter_path.curve = perimeter_curve


func clear_perimeter_path():
	for node in get_children():
		if node is Path3D:
			remove_child(node)
			node.queue_free()


func get_random_position() -> Vector3:
	var random_x = randf_range(min_bounds.x, max_bounds.x)
	var random_y = randf_range(min_bounds.y, max_bounds.y)
	var random_z = randf_range(min_bounds.z, max_bounds.z)
	
	return Vector3(random_x, random_y, random_z)

func get_random_position_in_polygon() -> Vector3:
	var random_position = Vector3.ZERO
	while true:
		random_position = get_random_position()
		if is_point_inside_polygon(random_position, towers):
			break
	return random_position




func add_evenly_spaced_points(curve: Curve3D, segment_length: int = 5, tolerance_length: = 20.0):
	if(!curve):
		return
	# Use tessellate_even_length to get points at regular intervals along the curve
	var even_points = curve.tessellate_even_length(segment_length, 1)
	
	## Optionally, you can add these points back into the curve or use them directly
	for point in even_points:
		curve.add_point(point)
	
	
	

func generate_sandbag_wall():
	if !perimeter_curve:
		print("No Curve Exists")
		return
	print("Generating Perimeter Sandbags")
	
	# Get baked points along the curve for even spacing
	var curve_points = perimeter_curve.get_baked_points()
	
	# Iterate through each point on the curve
	
	for i in range(curve_points.size() - 1):
		var point = curve_points[i]
		var next_point = curve_points[i + 1]
		
		# Calculate the direction vector between the current and next point
		var direction = (next_point - point).normalized()
		
		# Define the outward direction using the cross product with the UP axis
		var outward_vector = direction.cross(Vector3.UP).normalized()
		
		# Calculate the upward vector to maintain orthogonality in the basis
		var up_vector = outward_vector.cross(direction).normalized()
		
		# Set up the basis for the sandbag rotation
		var sandbag_basis = Basis(direction, up_vector, outward_vector)
		# Rotate the basis 90 degrees around the Y-axis
		sandbag_basis = sandbag_basis.rotated(Vector3.UP, deg_to_rad(90))
		
		
		# Instantiate and position the sandbag
		var sandbag = sandbag_scene.instantiate()
		add_child(sandbag)
		# This is a bug, I think I should be using the actual function call for get tree_root 
		sandbag.owner = get_tree().edited_scene_root
		sandbag.global_position = point
		sandbag.global_transform.basis = sandbag_basis
		sandbags.append(sandbag)

func clear_sandbag_wall():
	for node in sandbags:
		remove_child(node)
		node.queue_free()
	
	sandbags.clear()



func generate_gate():
	if !perimeter_curve:
		print("No Curve Exists")
		return

	print("Generating Gate")
	
	var curve_points = perimeter_curve.get_baked_points() # Get baked points along the curve
	# Get baked points along the curve for even spacing
	var random_index = randi_range(0, curve_points.size() - 1) # Random integer within bounds
	var random_position = curve_points[random_index] # Select random point
	var next_index = (random_index + 1) % curve_points.size() # Wrap-around for the next point
	var next_position = curve_points[next_index]
	var direction = (next_position - random_position).normalized()
	
	var outward_vector = direction.cross(Vector3.UP).normalized()
	
	# Calculate the upward vector to maintain orthogonality in the basis
	var up_vector = outward_vector.cross(direction).normalized()
	
	# Set up the basis for the sandbag rotation
	var gate_basis = Basis(direction, up_vector, outward_vector)
	# Rotate the basis 90 degrees around the Y-axis
	gate_basis = gate_basis.rotated(Vector3.UP, deg_to_rad(180))
	
	
		# Instantiate and position the sandbag
	gate = gate_scene.instantiate()
	add_child(gate)
	gate.owner = get_tree().edited_scene_root
	gate.global_position = random_position
	gate.basis = gate_basis
	
func clear_gate():
	if !gate:
		return
	remove_child(gate)
	gate.queue_free()
	gate = null




func generate_path_from_gate_to_base_center():
	if(!gate or !base_center):
		print("Need a gate AND base_center to generate road")
		return

	print("Generating Path from Gate to Base Center")


	var gateway_path = Path3D.new()
	add_child(gateway_path)
	gateway_path.owner = get_tree().edited_scene_root
	var gateway_curve = Curve3D.new()
	
	gateway_curve.add_point(gate.global_position)
	gateway_curve.add_point(base_center.global_position)
	
	# Close the path by adding the first point again at the end
	# gateway_curve.add_point(gateway_curve.get_point_position(0))
	
	gateway_path.curve = gateway_curve


func clear_gateway_path():
	print("TODO!!! ::Clearing Path")



func generate_paths_from_buildings_to_base_center():
	if(!buildings.size() or !base_center):
		print("Need buildings AND base_center to generate path")
		return
	print("Generating Paths from buildings to base center")
	
	for building in buildings:
			var building_path = Path3D.new()
			add_child(building_path)
			building_path.owner = get_tree().edited_scene_root
			var building_curve = Curve3D.new()
			
			building_curve.add_point(building.global_position)
			building_curve.add_point(base_center.global_position)
			
			# Close the path by adding the first point again at the end
			# gateway_curve.add_point(gateway_curve.get_point_position(0))
			
			building_path.curve = building_curve
	
