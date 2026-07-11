package main

import "core:math"
import rl "vendor:raylib"

update_projectiles :: proc(g: ^Game, dt: f32) {
	for i := 0; i < MAX_PROJECTILES; i += 1 {
		p := &g.projectiles[i]
		if !p.active {
			continue
		}

		if p.target_index < 0 || p.target_index >= g.enemy_count || !g.enemies[p.target_index].alive {
			p.active = false
			continue
		}

		target_pos := g.enemies[p.target_index].pos
		to_target := v_sub(target_pos, p.pos)
		dist := v_len(to_target)

		step := v_len(p.vel) * dt

		if step >= dist || dist < 8 {
			hit_projectile(g, p)
			p.active = false
		} else {
			dir := v_norm(to_target)
			p.pos = v_add(p.pos, v_mul(dir, step))
		}
	}
}

hit_projectile :: proc(g: ^Game, p: ^Projectile) {
	if p.splash_radius > 0 {
		r_sq := p.splash_radius * p.splash_radius
		center := g.enemies[p.target_index].pos

		for i := 0; i < g.enemy_count; i += 1 {
			if !g.enemies[i].alive {
				continue
			}

			if dist_sq(center, g.enemies[i].pos) <= r_sq {
				apply_damage_to_enemy(g, i, p.damage, p.damage_type)
			}
		}
	} else {
		apply_damage_to_enemy(g, p.target_index, p.damage, p.damage_type)
	}

	if p.slow_amount > 0 {
		apply_slow_to_enemy(g, p.target_index, p.slow_amount, p.slow_duration)
	}
	if p.burn_damage > 0 {
		apply_burn_to_enemy(g, p.target_index, p.burn_damage, p.burn_duration)
	}
	play_game_sound(g, .Impact)

	kind := Effect_Type.Spark
	if p.splash_radius > 30 { kind = .Explosion }
	if p.slow_amount > 0 { kind = .Frost_Burst }
	if p.burn_damage > 0 { kind = .Flame_Burst }
	spawn_effect(g, kind, g.enemies[p.target_index].pos, max(p.splash_radius, 10), p.color)
}

draw_projectiles :: proc(g: ^Game) {
	for i := 0; i < MAX_PROJECTILES; i += 1 {
		p := g.projectiles[i]
		if !p.active {
			continue
		}

		angle := f32(math.atan2(f64(p.vel.y), f64(p.vel.x)))*57.2958
		if !draw_asset(&g.assets, p.asset, p.pos, vec2(14,14), angle, rl.WHITE) {
			rl.DrawCircleV(p.pos, 5, p.color)
		}
	}
}
