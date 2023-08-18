class_name UnitData 
extends RefCounted

var max_health := 100
var max_stamina := 100
var regen := 100
var dodge := 100
var magic_defence := 10
var mundane_defence := 10
var attack := 50
var attack_speed := 100
var penetration := 100
var crit_chance := 100
var move_speed := 150
var stamina := 10
var num_units := 5
var faction := "faction1"
var gold_cost := 100
var tier := 1
var path_base_sprites := Constants.PATH_SPRITES_ACTORS
var actions := {}
var states: Array[Constants.ActorState] = []
var states_base_folder := "actor"

func _init(overrides := {}):
	for key in overrides:
		if key in self:
			set(key, overrides[key])
