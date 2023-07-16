class_name StatModifier extends Node
## simple data class to hold info for modifying [ActorStats]

var stat_name : String
var uid : int
var mod_type : Constants.StatModType
var amount : float

func _init(stat_name_: String, mod_type_: Constants.StatModType, amount_: float) -> void:
	stat_name = stat_name_
	mod_type = mod_type_
	amount = amount_

	## needs uid as expected to persist
	uid = Utility.generate_id()

