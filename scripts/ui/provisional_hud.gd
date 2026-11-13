class_name ProvisionalHud
extends CanvasLayer
## Temporary health and stamina bars until the real HUD (GDD §12.1, F2 task 10).
## Listens to the injected components; they do not know it exists.

@export var health: HealthComponent
@export var stamina: StaminaComponent
@export var health_bar: ProgressBar
@export var stamina_bar: ProgressBar


func _ready() -> void:
	assert(health_bar != null and stamina_bar != null, "ProvisionalHud needs its bars.")
	if health != null:
		health.health_changed.connect(_on_health_changed)
		_on_health_changed(health.current, health.get_maximum())
	if stamina != null:
		stamina.stamina_changed.connect(_on_stamina_changed)
		_on_stamina_changed(stamina.current, stamina.get_maximum())


func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current


func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current
