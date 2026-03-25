class_name OrbitStrategy
extends WeaponStrategy

var _orbit_weapons: Dictionary = {}

func on_weapon_added(data: WeaponData) -> void:
	var orbit = preload("res://scenes/weapons/orbit_weapon.tscn").instantiate()
	weapon_manager.add_child(orbit)
	orbit.setup(data, 1)
	_orbit_weapons[data.weapon_id] = orbit

func on_weapon_removed(weapon_id: String) -> void:
	if _orbit_weapons.has(weapon_id):
		_orbit_weapons[weapon_id].cleanup()
		_orbit_weapons[weapon_id].queue_free()
		_orbit_weapons.erase(weapon_id)

func fire(data: WeaponData, level: int) -> void:
	if _orbit_weapons.has(data.weapon_id):
		_orbit_weapons[data.weapon_id].refresh(data, level)
