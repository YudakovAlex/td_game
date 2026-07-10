package main

import "core:math"
import rl "vendor:raylib"

update_enemies :: proc(g: ^Game, dt: f32) {
	for i := 0; i < g.enemy_count; i += 1 {
		e := &g.enemies[i]
		if !e.alive {
			continue
		}

		if e.slow_timer > 0 {
			e.slow_timer -= dt
			if e.slow_timer <= 0 {
				e.slow_amount = 0
			}
		}
		if e.damage_flash > 0 { e.damage_flash -= dt }
		if e.burn_timer > 0 {
			e.burn_timer -= dt
			e.burn_tick -= dt
			if e.burn_tick <= 0 {
				apply_damage_to_enemy(g, i, e.burn_damage, .Elemental)
				e.burn_tick += 0.5
				spawn_effect(g, .Burn_Ember, e.pos, 6, rl.ORANGE)
			}
		}
		if !e.alive { continue }

		level := &g.levels[g.current_level]
		route := &level.routes[e.route_index]
		if e.path_index >= route.point_count {
			e.alive = false
			g.lives -= e.lives_damage
			g.enemies_leaked += 1
			continue
		}

		target := route.points[e.path_index]
		to_target := v_sub(target, e.pos)
		dist := v_len(to_target)

		speed := e.speed
		if e.slow_timer > 0 {
			speed *= 1.0 - e.slow_amount
		}

		step := speed * dt

		if step >= dist {
			e.pos = target
			e.path_index += 1
		} else {
			dir := v_norm(to_target)
			e.pos = v_add(e.pos, v_mul(dir, step))
		}
	}
}

cleanup_dead_enemies :: proc(g: ^Game) {
	i := 0
	for i < g.enemy_count {
		if !g.enemies[i].alive {
			g.enemies[i] = g.enemies[g.enemy_count-1]
			g.enemy_count -= 1
		} else {
			i += 1
		}
	}
}

apply_damage_to_enemy :: proc(g: ^Game, enemy_index: int, damage: f32, damage_type: Damage_Type) {
	if enemy_index < 0 || enemy_index >= g.enemy_count {
		return
	}

	e := &g.enemies[enemy_index]
	if !e.alive {
		return
	}

	final_damage := damage

	final_damage *= damage_multiplier(e.kind, damage_type)

	e.hp -= final_damage
	e.damage_flash = 0.10

	if e.hp <= 0 {
		e.alive = false
		g.gold += e.gold_reward
		g.enemies_defeated += 1
	}
}

damage_multiplier :: proc(kind: Enemy_Type, damage_type: Damage_Type) -> f32 {
	if kind == .Armored {
		if damage_type == .Physical { return 0.65 }
		if damage_type == .Magic { return 1.35 }
		return 1.0
	}
	if kind == .Brute && damage_type == .Physical { return 0.80 }
	if kind == .Brute && damage_type == .Magic { return 1.10 }
	if kind == .Boss { return 0.85 }
	return 1.0
}

apply_burn_to_enemy :: proc(g: ^Game, enemy_index: int, damage, duration: f32) {
	if enemy_index < 0 || enemy_index >= g.enemy_count || !g.enemies[enemy_index].alive { return }
	e := &g.enemies[enemy_index]
	if damage >= e.burn_damage { e.burn_damage = damage }
	e.burn_timer = duration
	if e.burn_tick <= 0 { e.burn_tick = 0.5 }
}

apply_slow_to_enemy :: proc(g: ^Game, enemy_index: int, amount, duration: f32) {
	if enemy_index < 0 || enemy_index >= g.enemy_count {
		return
	}

	e := &g.enemies[enemy_index]
	if !e.alive {
		return
	}

	actual_amount := amount
	if e.kind == .Boss {
		actual_amount *= 0.35
	}

	if actual_amount >= e.slow_amount {
		e.slow_amount = actual_amount
		e.slow_timer = duration
	}
}

draw_enemies :: proc(g: ^Game) {
	for i := 0; i < g.enemy_count; i += 1 {
		e := g.enemies[i]
		if !e.alive {
			continue
		}

		def := get_enemy_def(e.kind)

		size := f32(32)
		if e.kind == .Brute || e.kind == .Armored { size = 39 }
		if e.kind == .Boss { size = 52 }
		bob := f32(1.5) * f32(math.sin(f64(g.visual_time*5+f32(i))))
		rl.DrawEllipse(i32(e.pos.x), i32(e.pos.y+size*0.34), size*0.35, size*0.15, rl.Color{0,0,0,75})
		tint := rl.WHITE
		if e.slow_timer > 0 { tint = rl.Color{170,220,255,255} }
		if e.burn_timer > 0 { tint = rl.Color{255,175,105,255} }
		if e.damage_flash > 0 { tint = rl.Color{255,135,135,255} }
		if !draw_asset(&g.assets, def.asset, v_add(e.pos, vec2(0,bob)), vec2(size,size), 0, tint) {
			rl.DrawCircleV(e.pos, size*0.38, def.color)
			rl.DrawCircleLines(i32(e.pos.x), i32(e.pos.y), size*0.38, rl.BLACK)
		}

		w := f32(28)
		h := f32(5)
		hp_frac := e.hp / e.max_hp
		if hp_frac < 0 {
			hp_frac = 0
		}

		bar_x := e.pos.x - w/2
		bar_y := e.pos.y - size*0.65

		rl.DrawRectangle(i32(bar_x), i32(bar_y), i32(w), i32(h), rl.DARKGRAY)
		rl.DrawRectangle(i32(bar_x), i32(bar_y), i32(w*hp_frac), i32(h), rl.GREEN)

		if e.slow_timer > 0 {
			rl.DrawCircleLines(i32(e.pos.x), i32(e.pos.y), 17, rl.SKYBLUE)
		}
	}
}
