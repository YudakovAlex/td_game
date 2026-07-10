package main

init_waves :: proc(g: ^Game) {
	g.waves[0] = Wave_Def{.Grunt, 10, 0.65, 1.0, 1.0}
	g.waves[1] = Wave_Def{.Grunt, 15, 0.55, 1.1, 1.0}
	g.waves[2] = Wave_Def{.Runner, 10, 0.45, 1.0, 1.0}
	g.waves[3] = Wave_Def{.Grunt, 22, 0.45, 1.25, 1.0}
	g.waves[4] = Wave_Def{.Brute, 6, 0.95, 1.0, 1.0}
	g.waves[5] = Wave_Def{.Runner, 18, 0.38, 1.15, 1.0}
	g.waves[6] = Wave_Def{.Grunt, 28, 0.35, 1.45, 1.0}
	g.waves[7] = Wave_Def{.Brute, 10, 0.75, 1.3, 1.0}
	g.waves[8] = Wave_Def{.Runner, 24, 0.32, 1.45, 1.0}
	g.waves[9] = Wave_Def{.Boss, 1, 1.00, 1.0, 1.0}
	g.waves[10] = Wave_Def{.Armored, 7, 0.90, 1.0, 1.0}
	g.waves[11] = Wave_Def{.Grunt, 34, 0.28, 1.65, 1.0}
	g.waves[12] = Wave_Def{.Runner, 28, 0.27, 1.65, 1.05}
	g.waves[13] = Wave_Def{.Armored, 13, 0.72, 1.35, 1.0}
	g.waves[14] = Wave_Def{.Boss, 1, 1.00, 2.25, 1.08}

	g.wave_count = 15
}

try_start_wave :: proc(g: ^Game) {
	if g.wave_state != .Waiting {
		return
	}
	if g.current_wave >= g.wave_count {
		return
	}

	g.wave_state = .Spawning
	g.wave_spawned_count = 0
	g.wave_spawn_timer = 0
}

update_wave :: proc(g: ^Game, dt: f32) {
	if g.wave_state == .Spawning {
		wave := g.waves[g.current_wave]

		g.wave_spawn_timer -= dt

		if g.wave_spawn_timer <= 0 && g.wave_spawned_count < wave.count {
			spawn_enemy(g, wave)
			g.wave_spawned_count += 1
			g.wave_spawn_timer = wave.spawn_interval
		}

		if g.wave_spawned_count >= wave.count {
			g.wave_state = .Clearing
		}
	}

	if g.wave_state == .Clearing && g.enemy_count == 0 {
		g.current_wave += 1

		if g.current_wave >= g.wave_count {
			g.wave_state = .Finished
		} else {
			g.wave_state = .Waiting
			g.gold += 20
		}
	}
}

spawn_enemy :: proc(g: ^Game, wave: Wave_Def) {
	if g.enemy_count >= MAX_ENEMIES {
		return
	}

	def := get_enemy_def(wave.enemy_type)

	e := Enemy{}
	e.kind = wave.enemy_type
	e.pos = PATH_POINTS[0]
	e.path_index = 1
	e.max_hp = def.max_hp * wave.hp_mult
	e.hp = e.max_hp
	e.speed = def.speed * wave.speed_mult
	e.gold_reward = def.gold_reward
	e.lives_damage = def.lives_damage
	e.alive = true

	g.enemies[g.enemy_count] = e
	g.enemy_count += 1
}
