class_name VoidfireWall extends Node2D


func _ready():
	%WarningArea.area_entered.connect(Registry._on_ship_entered_warning_area)
	%DeathArea.area_entered.connect(Registry._on_ship_entered_death_area)
