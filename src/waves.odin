package main

init_levels :: proc(g: ^Game) {
	g.level_count = 3
	g.levels = {}
}

load_level :: proc(g: ^Game, level_index: int) {
	level := &g.levels[level_index]
	g.mode = .Playing
	g.restart_confirmation = false
	g.gold, g.lives = level.starting_gold, level.starting_lives
	g.enemies_defeated, g.enemies_leaked = 0, 0
	g.score_gold_earned, g.result_score = 0, 0
	g.result_saved = false
	g.selected_tower_type, g.selected_tower_index = .None, -1
	g.enemies = {}
	g.enemy_count = 0
	g.towers = {}
	g.tower_count = 0
	g.projectiles = {}
	g.effects = {}
	g.waves = level.waves
	g.wave_count = level.wave_count
	g.current_wave = 0
	g.wave_state = .Waiting
	g.wave_group_index = 0
	g.wave_spawned_count = 0
	g.wave_spawn_timer = 0
	g.wave_route_cursor = 0
	g.next_wave_timer = 0
	g.game_speed = 1
	init_map(g)
}

try_start_wave :: proc(g: ^Game) {
	if g.wave_state != .Waiting || g.current_wave >= g.wave_count { return }
	g.wave_state = .Spawning
	g.wave_group_index = 0
	g.wave_spawned_count = 0
	g.wave_spawn_timer = 0
	g.wave_route_cursor = 0
	g.next_wave_timer = 0
	play_game_sound(g, .Wave_Start)
	wave := g.waves[g.current_wave]
	for i := 0; i < wave.group_count; i += 1 {
		if wave.groups[i].enemy_type == .Boss {
			play_game_sound(g, .Boss)
			break
		}
	}
}

update_wave :: proc(g: ^Game, dt, raw_dt: f32) {
	if g.wave_state == .Waiting && g.next_wave_timer > 0 {
		g.next_wave_timer -= raw_dt
		if g.next_wave_timer <= 0 {
			g.next_wave_timer = 0
			try_start_wave(g)
		}
	}

	if g.wave_state == .Spawning {
		wave := g.waves[g.current_wave]
		group := wave.groups[g.wave_group_index]
		g.wave_spawn_timer -= dt
		if g.wave_spawn_timer <= 0 && g.wave_spawned_count < group.count {
			spawn_enemy(g,group)
			g.wave_spawned_count += 1
			g.wave_spawn_timer = group.spawn_interval
		}
		if g.wave_spawned_count >= group.count { g.wave_state = .Clearing }
	}
	if g.wave_state == .Clearing && g.enemy_count == 0 {
		wave := g.waves[g.current_wave]
		if g.wave_group_index+1 < wave.group_count {
			g.wave_group_index += 1
			g.wave_spawned_count = 0
			g.wave_spawn_timer = 0
			g.wave_state = .Spawning
		} else {
			g.current_wave += 1
			if g.current_wave >= g.wave_count { g.wave_state = .Finished
			} else {
				g.wave_state = .Waiting
				g.wave_group_index = 0
				g.gold += 20
				g.next_wave_timer = NEXT_WAVE_DELAY
			}
		}
	}
}

spawn_enemy :: proc(g: ^Game, group: Wave_Group) {
	if g.enemy_count >= MAX_ENEMIES { return }
	level := &g.levels[g.current_level]
	route_index := g.wave_route_cursor % level.route_count
	g.wave_route_cursor += 1
	route := &level.routes[route_index]
	def := get_enemy_def(g, group.enemy_type)
	e := Enemy{}
	e.kind = group.enemy_type
	e.route_index = route_index
	e.pos = route.points[0]
	e.path_index = 1
	e.max_hp = def.max_hp*group.hp_mult
	e.hp = e.max_hp
	e.speed = def.speed*group.speed_mult
	e.gold_reward, e.lives_damage = def.gold_reward, def.lives_damage
	e.alive = true
	g.enemies[g.enemy_count] = e
	g.enemy_count += 1
}
