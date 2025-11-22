extends Node

# autoload

const WEIGHTED_UIDS: Dictionary[String, int] = {
	
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
		progressed_weighted_list[key] = clampi(ceili(Stage.PROGRESS_ZENITH / clampf((progress_difference * weight_difference), 1.0, INF)), 1, INF) # no zero allowed
		total_weight += progressed_weighted_list[key]
	
	var accumulated: float = 0.0
	var random: float = randf() * total_weight
	
	for packedscene in progressed_weighted_list:
		accumulated += progressed_weighted_list[packedscene]
		if random < accumulated:
			return packedscene.instantiate()
	
	return null
