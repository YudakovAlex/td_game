package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

tower_at_tile :: proc(g: ^Game, tx, ty: int) -> int {
	for i := 0; i < g.tower_count; i += 1 {
		t := g.towers[i]
		if t.tile_x == tx && t.tile_y == ty {
			return i
		}
	}
	return -1
}

place_tower :: proc(g: ^Game, kind: Tower_Type, tx, ty: int) {
	if g.tower_count >= MAX_TOWERS {
		return
	}

	if g.tiles[ty][tx].kind != .Buildable {
		return
	}

	if tower_at_tile(g, tx, ty) >= 0 {
		return
	}

	def := get_tower_def(g, kind)

	if !TESTER_MODE && g.gold < def.cost {
		return
	}

	if !TESTER_MODE { g.gold -= def.cost }

	t := Tower{}
	t.kind = kind
	t.tile_x = tx
	t.tile_y = ty
	t.pos = tile_center(tx, ty)
	t.level = 1
	t.target_mode = .First
	t.cooldown_timer = 0
	t.total_invested = def.cost

	g.towers[g.tower_count] = t
	g.selected_tower_index = g.tower_count
	g.selected_tower_type = .None
	g.tower_count += 1
	play_game_sound(g, .Action)
}

upgrade_tower :: proc(g: ^Game, index: int) {
	if index < 0 || index >= g.tower_count {
		return
	}

	t := &g.towers[index]
	if t.level >= 3 {
		return
	}

	def := get_tower_def(g, t.kind)

	cost := upgrade_cost(t, def)

	if !TESTER_MODE && g.gold < cost {
		return
	}

	if !TESTER_MODE { g.gold -= cost }
	t.total_invested += cost
	t.level += 1
	play_game_sound(g, .Action)
}

upgrade_cost :: proc(t: ^Tower, def: Tower_Def) -> int {
	if t.level == 1 { return int(f32(def.cost)*1.5) }
	if t.level == 2 { return int(f32(def.cost)*3.0) }
	return 0
}

sell_tower :: proc(g: ^Game, index: int) {
	if index < 0 || index >= g.tower_count {
		return
	}

	refund := int(f32(g.towers[index].total_invested) * 0.70)
	g.gold += refund

	g.towers[index] = g.towers[g.tower_count-1]
	g.tower_count -= 1

	g.selected_tower_index = -1
	play_game_sound(g, .Action)
}

update_towers :: proc(g: ^Game, dt: f32) {
	for i := 0; i < g.tower_count; i += 1 {
		t := &g.towers[i]
		def := get_tower_def(g, t.kind)

		t.cooldown_timer -= dt
		if t.recoil > 0 { t.recoil -= dt*6 }
		if t.cooldown_timer > 0 {
			continue
		}

		target := find_tower_target(g, t, def)
		if target >= 0 {
			d := v_sub(g.enemies[target].pos, t.pos)
			t.aim_angle = f32(math.atan2(f64(d.y), f64(d.x)))*57.2958
			fire_projectile(g, t, def, target)
			t.recoil = 1
			t.cooldown_timer = tower_cooldown(t, def)
		}
	}
}

tower_damage :: proc(t: ^Tower, def: Tower_Def) -> f32 {
	level_mult := f32(1.0)
	if t.level == 2 {
		level_mult = 1.75
	} else if t.level == 3 {
		level_mult = 2.75
	}
	return def.damage * level_mult
}

tower_burn_damage :: proc(t: ^Tower, def: Tower_Def) -> f32 {
	if t.level == 2 { return def.burn_damage * 1.7 }
	if t.level == 3 { return def.burn_damage * 2.5 }
	return def.burn_damage
}

tower_range :: proc(t: ^Tower, def: Tower_Def) -> f32 {
	level_bonus := f32(0)
	if t.level == 3 {
		level_bonus = 20
	}
	return def.range + level_bonus
}

tower_cooldown :: proc(t: ^Tower, def: Tower_Def) -> f32 {
	if t.level == 3 {
		return def.cooldown * 0.82
	}
	return def.cooldown
}

next_target_mode :: proc(mode: Target_Mode) -> Target_Mode {
	switch mode {
	case .First:
		return .Weakest
	case .Weakest:
		return .Strongest
	case .Strongest:
		return .First
	}
	return .First
}

cycle_tower_target_mode :: proc(g: ^Game, index: int) {
	if index < 0 || index >= g.tower_count {
		return
	}

	g.towers[index].target_mode = next_target_mode(g.towers[index].target_mode)
	play_game_sound(g, .Action)
}

enemy_route_progress :: proc(g: ^Game, e: ^Enemy) -> f32 {
	if g.current_level < 0 || g.current_level >= g.level_count {
		return f32(e.path_index)
	}

	level := &g.levels[g.current_level]
	if e.route_index < 0 || e.route_index >= level.route_count {
		return f32(e.path_index)
	}

	route := &level.routes[e.route_index]
	if route.point_count < 2 {
		return f32(e.path_index)
	}
	if e.path_index <= 0 {
		return 0
	}

	total_length: f32 = 0
	for i := 1; i < route.point_count; i += 1 {
		total_length += v_len(v_sub(route.points[i], route.points[i-1]))
	}
	if total_length <= 0 {
		return f32(e.path_index)
	}

	if e.path_index >= route.point_count {
		return 1
	}

	progress_length: f32 = 0
	for i := 1; i < e.path_index; i += 1 {
		progress_length += v_len(v_sub(route.points[i], route.points[i-1]))
	}

	segment_start := route.points[e.path_index-1]
	segment_end := route.points[e.path_index]
	segment_length := v_len(v_sub(segment_end, segment_start))
	segment_progress := v_len(v_sub(e.pos, segment_start))
	if segment_progress < 0 { segment_progress = 0 }
	if segment_progress > segment_length { segment_progress = segment_length }
	progress_length += segment_progress

	return progress_length / total_length
}

target_is_better :: proc(
	mode: Target_Mode,
	candidate: Enemy,
	candidate_progress: f32,
	candidate_index: int,
	current: Enemy,
	current_progress: f32,
	current_index: int,
) -> bool {
	if mode == .Weakest && candidate.hp != current.hp {
		return candidate.hp < current.hp
	}
	if mode == .Strongest && candidate.hp != current.hp {
		return candidate.hp > current.hp
	}

	if candidate_progress != current_progress {
		return candidate_progress > current_progress
	}
	if candidate.route_index != current.route_index {
		return candidate.route_index < current.route_index
	}
	return candidate_index < current_index
}

find_tower_target :: proc(g: ^Game, t: ^Tower, def: Tower_Def) -> int {
	best := -1

	r := tower_range(t, def)
	r_sq := r * r

	for i := 0; i < g.enemy_count; i += 1 {
		e := g.enemies[i]
		if !e.alive {
			continue
		}

		if dist_sq(t.pos, e.pos) > r_sq {
			continue
		}

		candidate_progress := enemy_route_progress(g, &e)
		current_progress: f32 = 0
		if best >= 0 {
			current_progress = enemy_route_progress(g, &g.enemies[best])
		}

		if best < 0 || target_is_better(t.target_mode, e, candidate_progress, i, g.enemies[best], current_progress, best) {
			best = i
		}
	}

	return best
}

fire_projectile :: proc(g: ^Game, t: ^Tower, def: Tower_Def, target_index: int) {
	for i := 0; i < MAX_PROJECTILES; i += 1 {
		if !g.projectiles[i].active {
			target_pos := g.enemies[target_index].pos
			dir := v_norm(v_sub(target_pos, t.pos))

			p := Projectile{}
			p.active = true
			p.pos = t.pos
			p.vel = v_mul(dir, def.projectile_spd)

			p.target_index = target_index
			p.damage = tower_damage(t, def)
			p.damage_type = def.damage_type
			p.splash_radius = def.splash_radius

			p.slow_amount = def.slow_amount
			p.slow_duration = def.slow_duration
			p.burn_damage = tower_burn_damage(t, def)
			p.burn_duration = def.burn_duration
			p.asset = projectile_asset(t.kind)
			if t.kind == .Flame && t.level == 3 { p.splash_radius += 14 }

			p.color = def.color

			g.projectiles[i] = p
			return
		}
	}
}

draw_towers :: proc(g: ^Game) {
	for i := 0; i < g.tower_count; i += 1 {
		t := g.towers[i]
		def := get_tower_def(g, t.kind)

		color := def.color

		rl.DrawEllipse(i32(t.pos.x), i32(t.pos.y+12), 17, 8, rl.Color{0,0,0,75})
		rl.DrawCircleV(t.pos, 17, rl.Color{80,70,55,255})
		pos := v_sub(t.pos, v_mul(vec2(f32(math.cos(f64(t.aim_angle/57.2958))), f32(math.sin(f64(t.aim_angle/57.2958)))), t.recoil*2))
		if !draw_asset(&g.assets, def.asset, pos, vec2(38,38), t.aim_angle, rl.WHITE) {
			rl.DrawCircleV(t.pos, 15, color)
			rl.DrawCircleLines(i32(t.pos.x), i32(t.pos.y), 15, rl.BLACK)
		}

		level_text := fmt.tprintf("%d", t.level)
		draw_text(level_text, int(t.pos.x+10), int(t.pos.y+8), 14, rl.GOLD)

		if i == g.selected_tower_index {
			r := tower_range(&g.towers[i], def)
			rl.DrawCircleV(t.pos, r, rl.Color{55,110,210,28})
			rl.DrawCircleLines(i32(t.pos.x), i32(t.pos.y), r, rl.SKYBLUE)
		}
	}
}
