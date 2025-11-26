extends Node

# autoload

const WEIGHTED_UIDS: Dictionary[String, int] = {
	"uid://ccf636mp186jm": 500,
	"uid://fi80wq3j8js2": 800,
	"uid://3npqjbw1eov2": 200
	}

var weighted_list: Dictionary[PackedScene, int] = {}


func _ready():
	setup_entities_list()


# Assign the weight value into an effectively pre-loaded list of scenes
func setup_entities_list():
	for key in WEIGHTED_UIDS:
		var new_packedscene_reference: PackedScene = load(key)
		weighted_list[new_packedscene_reference] = WEIGHTED_UIDS[key]


func get_entity(progress: float) -> Entity:
	var progressed_weighted_list: Dictionary[PackedScene, int] = {}
	var progress_difference: float = Stage.PROGRESS_ZENITH - progress
	var total_weight: float = 0.0
	
	for key in weighted_list:
		var weight_difference: float = Stage.PROGRESS_ZENITH - weighted_list[key]
		var progress_weight_factor: float = clampf((progress_difference * weight_difference), 1.0, INF)
		var weight_adjustment: float = Stage.PROGRESS_ZENITH / progress_weight_factor
		progressed_weighted_list[key] = clampi(ceili(weight_adjustment), 1, 99999) # no zero allowed
		total_weight += progressed_weighted_list[key]
	
	var accumulated: float = 0.0
	var random: float = randf() * total_weight
	
	for packedscene in progressed_weighted_list:
		accumulated += progressed_weighted_list[packedscene]
		if accumulated > random:
			var new_entity: Entity = packedscene.instantiate()
			return new_entity
	
	return null
