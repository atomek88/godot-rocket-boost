extends RigidBody3D

## How much vertical thrust to apply when moving
@export_range(500.0, 3000.0) var thrust: float = 1000.0
@export var torque_thrust: float = 100.0
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_boost_particles: GPUParticles3D = $RightBoostParticles
@onready var left_boost_particles: GPUParticles3D = $LeftBoostParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

var is_transitioning: bool = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed('boost'):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if rocket_audio.playing == false:
			rocket_audio.play()
	else:
		rocket_audio.stop()
		booster_particles.emitting = false
		
	if Input.is_action_pressed('rotate_left'):
		left_boost_particles.emitting = true
		apply_torque(Vector3(0.0,0.0,torque_thrust * delta))
	else:
		left_boost_particles.emitting = false
	if Input.is_action_pressed('rotate_right'):
		right_boost_particles.emitting = true
		apply_torque(Vector3(0.0,0.0,-torque_thrust * delta))
	else:
		right_boost_particles.emitting = false


func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		if "LevelFloor" in body.get_groups():
			crash_sequence()

func set_tween_transition() -> Tween:
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(1.7)
	return tween
	
func crash_sequence() -> void:
	print('kaboom')
	explosion_audio.play()
	explosion_particles.emitting = true
	var tween = set_tween_transition()
	tween.tween_callback(get_tree().reload_current_scene)
	
func complete_level(next_level_file: String) -> void:
	print('Level Complete!')
	success_audio.play()
	success_particles.emitting = true
	var tween = set_tween_transition()
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))

