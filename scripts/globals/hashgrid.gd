extends Node

var hash_grid : Dictionary
var tile_size := Vector2(25,25)

const offsets : Array [Vector2] = [
	Vector2(-1,1),Vector2(0,1),Vector2(1,1),
	Vector2(-1,0),Vector2(0,0),Vector2(1,0),
	Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1)
]

func _ready():
	self.process_priority = -4

func _physics_process(_delta):
	hash_grid.clear()
	for actor in get_tree().get_nodes_in_group("actor"):
		var tile = (actor.global_position / tile_size).floor()
		if not hash_grid.has(tile):
			hash_grid[tile] = []
		hash_grid[tile].append(actor)
	
	for tile in hash_grid.keys():
		var supa_list : Array[Actor]
		for offset in offsets:
			var t_tile = tile + offset
			if hash_grid.has(t_tile):
				supa_list.append_array(hash_grid[t_tile])
		for actor in hash_grid[tile]:
			actor.neighbours = supa_list
