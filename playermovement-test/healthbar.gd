extends Control

@export var max_health: float = 100.0  # Maximum health value
@export var health: float = 100.0  # Current health
@export var max_mana: float = 100.0  # Maximum mana value
@export var mana: float = 100.0  # Current mana
@export var mana_drain_rate: float = 15.0  # Mana decrease per second when holding C
@export var health_gain_rate: float = 10.0  # Health increase per second after 2s hold

@onready var health_bar1 = $HealthBar1  # Health: 0–30
@onready var health_bar2 = $HealthBar2  # Health: 30–50
@onready var health_bar3 = $HealthBar3  # Health: 50–80
@onready var health_bar4 = $HealthBar4  # Health: 80–100
@onready var mana_bar1 = $Manabar1  # Mana: 0–50
@onready var mana_bar2 = $Manabar2  # Mana: 50–100

var is_holding_c: bool = false  # Tracks if C key is held
var c_hold_time: float = 0.0  # Duration C has been held
var is_healing: bool = false  # Tracks if healing is active (after 2s)
var is_holding_d: bool = false  # Tracks if D key is held

func _ready():
	# Initialize health bar ranges
	health_bar1.min_value = 0
	health_bar1.max_value = 30
	health_bar2.min_value = 30
	health_bar2.max_value = 50
	health_bar3.min_value = 50
	health_bar3.max_value = 80
	health_bar4.min_value = 80
	health_bar4.max_value = 100
	
	# Initialize mana bar ranges
	mana_bar1.min_value = 0
	mana_bar1.max_value = 50
	mana_bar2.min_value = 50
	mana_bar2.max_value = 100
	
	update_bars()  # Initialize bars

func _process(delta):
	# Handle C key input (mana drain and delayed healing, only if health < max_health)
	if Input.is_action_just_pressed("Charge"):
		is_holding_c = true
		c_hold_time = 0.0
		is_healing = false
	if Input.is_action_just_released("Charge"):
		is_holding_c = false
		is_healing = false
		c_hold_time = 0.0
	if is_holding_c and health < max_health:
		c_hold_time += delta
		
		mana = clamp(mana - mana_drain_rate * delta, 0, max_mana)
		
		# Start healing after 2 seconds
		if c_hold_time >= 1.5 and mana > 0:
			is_healing = true
			health = clamp(health + health_gain_rate * delta, 0, max_health)
	
	# Handle D key input (health drain for testing)
	if Input.is_action_just_pressed("Fireball"):  # E.g., Spacebar
		change_mana(-10)
	
	update_bars()

func take_damage():
	change_health(-10)

func update_bars():
	# Update health bars
	health_bar1.value = clamp(health, health_bar1.min_value, health_bar1.max_value)
	health_bar2.value = clamp(health, health_bar2.min_value, health_bar2.max_value) if health > health_bar2.min_value else health_bar2.min_value
	health_bar3.value = clamp(health, health_bar3.min_value, health_bar3.max_value) if health > health_bar3.min_value else health_bar3.min_value
	health_bar4.value = clamp(health, health_bar4.min_value, health_bar4.max_value) if health > health_bar4.min_value else health_bar4.min_value
	
	# Update mana bars
	mana_bar1.value = clamp(mana, mana_bar1.min_value, mana_bar1.max_value)
	mana_bar2.value = clamp(mana, mana_bar2.min_value, mana_bar2.max_value) if mana > mana_bar2.min_value else mana_bar2.min_value

# Optional: Example function for external damage/healing or mana changes
func change_health(amount: float):
	health = clamp(health + amount, 0, max_health)
	update_bars()

func change_mana(amount: float):
	mana = clamp(mana + amount, 0, max_mana)
	update_bars()
