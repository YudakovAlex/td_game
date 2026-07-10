package main

import rl "vendor:raylib"

spawn_effect :: proc(g: ^Game, kind: Effect_Type, pos: Vec2, radius: f32, color: rl.Color) {
	for i := 0; i < MAX_EFFECTS; i += 1 {
		if !g.effects[i].active {
			lifetime := f32(0.24)
			if kind == .Explosion { lifetime = 0.38 }
			if kind == .Burn_Ember || kind == .Portal { lifetime = 0.55 }
			g.effects[i] = Visual_Effect{true, kind, pos, radius, 0, lifetime, color}
			return
		}
	}
}

update_effects :: proc(g: ^Game, dt: f32) {
	for i := 0; i < MAX_EFFECTS; i += 1 {
		if !g.effects[i].active { continue }
		g.effects[i].age += dt
		if g.effects[i].age >= g.effects[i].lifetime { g.effects[i].active = false }
	}
}

draw_effects :: proc(g: ^Game) {
	for e in g.effects {
		if !e.active { continue }
		p := e.age / e.lifetime
		alpha := u8(255.0 * (1.0-p))
		c := e.color
		c.a = alpha
		switch e.kind {
		case .Spark:
			rl.DrawLineEx(v_add(e.pos, vec2(-8*(1-p), 0)), v_add(e.pos, vec2(8*(1-p), 0)), 2, c)
			rl.DrawLineEx(v_add(e.pos, vec2(0, -8*(1-p))), v_add(e.pos, vec2(0, 8*(1-p))), 2, c)
		case .Explosion:
			rl.DrawCircleLines(i32(e.pos.x), i32(e.pos.y), e.radius*p, c)
			rl.DrawCircleV(e.pos, e.radius*(1-p)*0.45, rl.Color{c.r,c.g,c.b,alpha/3})
		case .Frost_Burst:
			rl.DrawPoly(e.pos, 6, e.radius*p, p*30, c)
		case .Flame_Burst, .Burn_Ember:
			rl.DrawCircleV(v_add(e.pos, vec2(0, -p*10)), e.radius*(1-p), c)
		case .Portal:
			rl.DrawCircleLines(i32(e.pos.x), i32(e.pos.y), e.radius*(0.8+p*0.2), c)
		}
	}
}
