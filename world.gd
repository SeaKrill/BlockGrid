extends Node
 
var object = null
 
var radius := 2
var map := {}
 
var putPos : Vector3 = Vector3.ZERO
 
var t = ["block1"]
 
func _mouse_pos():
	var camera = $Camera3D
	var mouse = get_viewport().get_mouse_position()
	var result = camera.project_position(mouse, 10.0)
	return Vector3(result.x, 0, result.z).snapped(Vector3(1,0.5,1))
	
func _ready():
	_spawn_block()
	
func _physics_process(delta):
	var tar = _mouse_pos() - Vector3(object.size.x/2, 0, object.size.z/2)
	var p = _update_target(tar, object)
	object.global_position = putPos
	
	if Input.is_action_just_pressed("ui_accept"):
		if !p: return
		_mark_block(putPos, object.size)
		_spawn_block()
		
func _spawn_block():
	var x = t[randi() % t.size()]
	var loaded = load("res://%s.tscn" % x)
	object = loaded.instantiate()
	object.get_child(0).position = Vector3(object.size.x/2, 0, object.size.z/2)
	object.get_child(0).material.albedo_color = Color(randi_range(0,4),randi_range(0,4),randi_range(0,4),1)
	add_child(object)
		
func _update_target(target: Vector3, block: Node3D):
	var check = false
	var range = _get_radius(target)
	var c = null
	for i in range:
		var hasBlock = _has_block(i, block.size)
		if not hasBlock and (c == null or i.distance_to(target) < c.distance_to(target)):
			check = true
			c = i
	if c != null: putPos = c
	return check
 
func _get_radius(target: Vector3):
	var result := []
	for x in range(-radius, radius + 1):
		for z in range(-radius, radius + 1):
			var point = Vector3(target.x + x, 0, target.z + z)
			result.append(point)
	return result
	
func _has_block(p: Vector3, s: Vector3):
	for x in range(s.x):
		for z in range(s.z):
			var key = Vector3(p.x + x, p.y, p.z + z)
			if map.has(key):
				return true
	return false
	
func _mark_block(p: Vector3, s: Vector3):
	for x in range(s.x):
		for z in range(s.z):
			map[Vector3(p.x + x, p.y, p.z + z)] = object
