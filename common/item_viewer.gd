@tool
extends Node3D
class_name ItemViewer

enum ItemType { GUN, GRENADE, BANDAGES }


@export var item_type := ItemType.GUN:
	set(value):
		item_type = value
		if not is_node_ready():
			await ready
		_gun.visible = item_type == ItemType.GUN
		_grenade.visible = item_type == ItemType.GRENADE
		_bandages.visible = item_type == ItemType.BANDAGES


@onready var _gun: Node3D = %Gun
@onready var _grenade: Node3D = %Grenade
@onready var _bandages: Node3D = %Bandages
