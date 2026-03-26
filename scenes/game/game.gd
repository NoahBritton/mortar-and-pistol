extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D

var _heal_spawn_timer: float = 0.0
var _heal_spawn_interval: float = 20.0  # seconds between heal spawns
var _lodestone_spawn_timer: float = 0.0
var _lodestone_spawn_interval: float = 45.0
var _prev_player_hp: int = -1
var _pending_evolutions: Array[EvolutionData] = []  # Queued for next level-up

func _ready() -> void:
	# Register object pools
	PoolManager.register_pool("enemy", preload("res://scenes/enemies/base_enemy.tscn"), 50)
	PoolManager.register_pool("projectile", preload("res://scenes/weapons/base_projectile.tscn"), 100)
	PoolManager.register_pool("xp_gem", preload("res://scenes/pickups/xp_gem.tscn"), 200)
	PoolManager.register_pool("damage_number", preload("res://scenes/ui/damage_number.tscn"), 50)
	PoolManager.register_pool("aoe_effect", preload("res://scenes/weapons/aoe_effect.tscn"), 10)
	PoolManager.register_pool("chain_effect", preload("res://scenes/weapons/chain_effect.tscn"), 10)
	PoolManager.register_pool("melee_effect", preload("res://scenes/weapons/melee_effect.tscn"), 10)
	PoolManager.register_pool("toxic_zone", preload("res://scenes/weapons/toxic_zone.tscn"), 15)
	PoolManager.register_pool("homing_missile", preload("res://scenes/weapons/homing_missile.tscn"), 30)
	PoolManager.register_pool("heal_pickup", preload("res://scenes/pickups/heal_pickup.tscn"), 10)
	PoolManager.register_pool("scatter_flask", preload("res://scenes/weapons/scatter_flask_projectile.tscn"), 10)
	PoolManager.register_pool("powder_keg", preload("res://scenes/weapons/powder_keg_mine.tscn"), 10)
	PoolManager.register_pool("beam_effect", preload("res://scenes/weapons/beam_effect.tscn"), 10)
	PoolManager.register_pool("lodestone_pulse", preload("res://scenes/pickups/lodestone_pulse.tscn"), 5)

	# Connect signals
	SignalBus.player_leveled_up.connect(_on_player_leveled_up)
	SignalBus.player_died.connect(_on_player_died)
	SignalBus.enemy_killed.connect(_on_enemy_killed)
	SignalBus.damage_dealt.connect(_on_damage_dealt)
	SignalBus.upgrade_chosen.connect(_on_upgrade_chosen)
	SignalBus.evolution_chosen.connect(_on_evolution_chosen)
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.screen_shake_requested.connect(_on_screen_shake)

	# Give player starting weapon based on selected character
	var char_data = GameManager.CHARACTER_DATA[GameManager.selected_character]
	var starting_weapon = WeaponsDB.get_weapon(char_data.weapon_id)
	GameManager.add_weapon(starting_weapon)
	player.get_node("WeaponManager").add_weapon(starting_weapon)
	PassiveEffects.reset()

	# Set player color to match character
	player.get_node("ColorRect").color = char_data.color
	player._base_color = char_data.color

	SignalBus.game_started.emit()

func _process(delta: float) -> void:
	if GameManager.is_game_active:
		GameManager.elapsed_time += delta
		SignalBus.wave_timer_updated.emit(GameManager.elapsed_time)
		_heal_spawn_timer += delta
		if _heal_spawn_timer >= _heal_spawn_interval:
			_heal_spawn_timer = 0.0
			_heal_spawn_interval = randf_range(15.0, 30.0)
			_spawn_heal_pickup()
		_lodestone_spawn_timer += delta
		if _lodestone_spawn_timer >= _lodestone_spawn_interval:
			_lodestone_spawn_timer = 0.0
			_lodestone_spawn_interval = randf_range(30.0, 60.0)
			_spawn_lodestone_pulse()
	camera.global_position = player.global_position
	$CheckeredFloor.global_position = player.global_position

func _on_player_leveled_up(_new_level: int) -> void:
	AudioManager.play(AudioManager.sfx_level_up)
	if GameManager.god_mode:
		GameManager.pending_levels = 0
		return
	_show_next_level_up()

func _show_next_level_up() -> void:
	if GameManager.pending_levels <= 0:
		get_tree().paused = false
		return
	get_tree().paused = true

	# Check if evolutions are ready — show evo popup before normal level-up
	if not _pending_evolutions.is_empty():
		# Group by base weapon
		var by_weapon: Dictionary = {}
		for rule in _pending_evolutions:
			if not by_weapon.has(rule.base_weapon_id):
				by_weapon[rule.base_weapon_id] = []
			by_weapon[rule.base_weapon_id].append(rule)
		# Show popup for the first weapon group
		var first_key = by_weapon.keys()[0]
		var rules_for_weapon: Array[EvolutionData] = []
		for r in by_weapon[first_key]:
			rules_for_weapon.append(r)
		var evo_panel = $CanvasLayer/EvolutionPopup
		if evo_panel:
			evo_panel.show_evolution_choices(rules_for_weapon)
		return

	var panel = $CanvasLayer/LevelUpPanel
	if panel:
		if panel.has_upgrades_available():
			panel.show_upgrades()
		else:
			GameManager.pending_levels = 0
			GameManager.heal(GameManager.player_max_hp + GameManager.max_hp_bonus)
			get_tree().paused = false

func _on_player_died() -> void:
	get_tree().paused = true
	var panel = $CanvasLayer/GameOverPanel
	if panel:
		panel.show_results()

func _on_enemy_killed(enemy_position: Vector2) -> void:
	GameManager.add_kill()
	AudioManager.play(AudioManager.sfx_kill)
	_spawn_xp_gem(enemy_position)

func _on_damage_dealt(pos: Vector2, amount: int) -> void:
	AudioManager.play(AudioManager.sfx_hit)
	var dmg_num = PoolManager.acquire("damage_number")
	if dmg_num:
		dmg_num.reset(pos, amount)

func _on_upgrade_chosen(choice: Dictionary) -> void:
	GameManager.apply_choice(choice)

	# Sync weapon manager with inventory changes
	var wm = player.get_node("WeaponManager")
	match choice.type:
		"new_weapon":
			wm.add_weapon(choice.data)

	# Queue newly-eligible evolutions for next level-up (don't apply instantly)
	_queue_pending_evolutions()

	# Consume one pending level, then show next if any remain
	GameManager.pending_levels -= 1
	_show_next_level_up()

func _on_evolution_chosen(rule: EvolutionData) -> void:
	var wm = player.get_node("WeaponManager")
	var evolved = WeaponsDB.get_weapon(rule.evolved_weapon_id)
	if evolved:
		GameManager.evolve_weapon(rule.base_weapon_id, evolved)
		wm.replace_weapon(rule.base_weapon_id, evolved)
	# Remove all pending evo rules for this base weapon
	_pending_evolutions = _pending_evolutions.filter(func(r): return r.base_weapon_id != rule.base_weapon_id)
	# Consume one pending level for the evo, then continue
	GameManager.pending_levels -= 1
	_show_next_level_up()

func _queue_pending_evolutions() -> void:
	var available = GameManager.check_evolutions()
	for rule in available:
		# Don't double-queue
		var already_queued = false
		for existing in _pending_evolutions:
			if existing.evolved_weapon_id == rule.evolved_weapon_id:
				already_queued = true
				break
		if not already_queued:
			_pending_evolutions.append(rule)

func _spawn_xp_gem(pos: Vector2) -> void:
	var gem = PoolManager.acquire("xp_gem")
	if gem:
		var minutes = GameManager.elapsed_time / 60.0
		var value = int(5 + minutes * 2)
		gem.reset(pos, value)

func _on_player_health_changed(current: int, _max_hp: int) -> void:
	if _prev_player_hp >= 0 and current < _prev_player_hp:
		AudioManager.play(AudioManager.sfx_player_hurt)
	_prev_player_hp = current

func _spawn_heal_pickup() -> void:
	var pickup = PoolManager.acquire("heal_pickup")
	if pickup:
		var angle = randf() * TAU
		var dist = randf_range(150.0, 350.0)
		var pos = player.global_position + Vector2(cos(angle), sin(angle)) * dist
		var minutes = GameManager.elapsed_time / 60.0
		var amount = int(15 + minutes * 3)
		pickup.reset(pos, amount)

func _on_screen_shake(intensity: float, duration: float) -> void:
	var tween = create_tween()
	var steps = 4
	var step_time = duration / steps
	for i in steps:
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(camera, "offset", offset, step_time)
	tween.tween_property(camera, "offset", Vector2.ZERO, step_time * 0.5)

func _spawn_lodestone_pulse() -> void:
	var pickup = PoolManager.acquire("lodestone_pulse")
	if pickup:
		var angle = randf() * TAU
		var dist = randf_range(100.0, 300.0)
		var pos = player.global_position + Vector2(cos(angle), sin(angle)) * dist
		pickup.reset(pos)
