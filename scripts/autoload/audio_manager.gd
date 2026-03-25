extends Node

# Pooled AudioStreamPlayers for overlapping sounds
var _players: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 16

# Per-sound cooldown to prevent stacking (same sound won't replay within this window)
const DEDUP_MS: int = 50
var _last_play_times: Dictionary = {}

# ── Gameplay SFX (jsfxr) ──
var sfx_shoot: AudioStream = preload("res://assets/sfx/jsfxr/laserShoot_short.wav")
var sfx_hit: AudioStream = preload("res://assets/sfx/jsfxr/hitHurt.wav")
var sfx_kill: AudioStream = preload("res://assets/sfx/jsfxr/explosion.wav")
var sfx_pickup: AudioStream = preload("res://assets/sfx/jsfxr/pickupCoin.wav")
var sfx_level_up: AudioStream = preload("res://assets/sfx/jsfxr/powerUp.wav")
var sfx_player_hurt: AudioStream = preload("res://assets/sfx/jsfxr/deathSound.wav")

# ── UI SFX ──
var sfx_ui_hover: AudioStream = preload("res://assets/sfx/jsfxr/menuHover.wav")
var sfx_ui_click: AudioStream = preload("res://assets/sfx/jsfxr/menuConfirm.wav")
var sfx_ui_open: AudioStream = preload("res://assets/sfx/jsfxr/uiOpen.wav")
var sfx_ui_close: AudioStream = preload("res://assets/sfx/kenney_digital-audio/Audio/lowDown.ogg")

func _ready() -> void:
	for i in POOL_SIZE:
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)

func play(stream: AudioStream, volume_db: float = 0.0) -> void:
	# Dedup: skip if same sound played within DEDUP_MS
	var now = Time.get_ticks_msec()
	var id = stream.resource_path
	if _last_play_times.has(id) and (now - _last_play_times[id]) < DEDUP_MS:
		return
	_last_play_times[id] = now

	for p in _players:
		if not p.playing:
			p.stream = stream
			p.volume_db = volume_db
			p.play()
			return

## Wire hover + click sounds onto any Button node.
func wire_button_sfx(button: BaseButton) -> void:
	button.mouse_entered.connect(func(): play(sfx_ui_hover, -6.0))
	button.pressed.connect(func(): play(sfx_ui_click, -3.0))
