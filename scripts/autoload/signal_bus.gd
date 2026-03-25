extends Node

signal player_health_changed(current_hp: int, max_hp: int)
signal player_died
signal player_leveled_up(new_level: int)

signal xp_gained(amount: int)

signal enemy_killed(enemy_position: Vector2)
signal damage_dealt(position: Vector2, amount: int)

signal game_started
signal game_over
signal upgrade_chosen(choice: Dictionary)

signal wave_timer_updated(elapsed_seconds: float)
signal inventory_changed
signal player_dashed(cooldown_duration: float)
signal screen_shake_requested(intensity: float, duration: float)
