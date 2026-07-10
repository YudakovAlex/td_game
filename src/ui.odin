package main

import "core:fmt"
import rl "vendor:raylib"

game_render_target: rl.RenderTexture2D

draw_text :: proc(text: string, x, y, font_size: int, color: rl.Color) {
	text_c := fmt.ctprintf("%s", text)
	rl.DrawText(text_c, i32(x), i32(y), i32(font_size), color)
}

draw_game :: proc(g: ^Game) {
	vp := get_viewport()

	rl.BeginTextureMode(game_render_target)
	rl.ClearBackground(rl.RAYWHITE)

	draw_map(g)
	draw_path(g)
	draw_build_preview(g)
	draw_towers(g)
	draw_enemies(g)
	draw_projectiles(g)
	draw_effects(g)
	draw_ui(g)

	switch g.mode {
	case .Victory:
		if g.current_level+1 < g.level_count {
			draw_result_message(g, "LEVEL COMPLETE", "Continue", rl.DARKGREEN)
		} else {
			draw_result_message(g, "CAMPAIGN COMPLETE", "", rl.GOLD)
		}
	case .Defeat:
		draw_result_message(g, "DEFEAT", "Retry", rl.RED)
	case .Paused:
		draw_pause_message(g)
	case .Playing:
	}
	rl.EndTextureMode()

	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.Color{18, 18, 22, 255})

	source := rl.Rectangle{
		x      = 0,
		y      = 0,
		width  = f32(game_render_target.texture.width),
		height = -f32(game_render_target.texture.height),
	}
	dest := rl.Rectangle{
		x      = vp.offset_x,
		y      = vp.offset_y,
		width  = vp.width,
		height = vp.height,
	}

	rl.DrawTexturePro(game_render_target.texture, source, dest, vec2(0, 0), 0, rl.WHITE)
}

draw_ui :: proc(g: ^Game) {
	rl.DrawRectangle(i32(UI_X), 0, i32(UI_W), SCREEN_HEIGHT, rl.Color{29, 27, 31, 255})
	rl.DrawRectangle(i32(UI_X), 0, 5, SCREEN_HEIGHT, rl.Color{126, 95, 52, 255})

	x := UI_X + 20
	y := 14

	draw_text(fmt.tprintf("%d/%d  %s",g.current_level+1,g.level_count,g.levels[g.current_level].name), x, y, 22, rl.Color{235,218,174,255})

	y = 44
	draw_icon_or_glyph(g, .Icon_Gold, vec2(f32(x+10),f32(y+10)), rl.GOLD)
	draw_text(fmt.tprintf("Gold: %d", g.gold), x+28, y, 20, rl.GOLD)

	draw_icon_or_glyph(g, .Icon_Lives, vec2(f32(x+140),f32(y+10)), rl.RED)
	draw_text(fmt.tprintf("Lives: %d", g.lives), x+158, y, 20, rl.RED)

	y = 78
	draw_icon_or_glyph(g, .Icon_Wave, vec2(f32(x+10),f32(y+10)), rl.RAYWHITE)
	draw_text(fmt.tprintf("Wave %d / %d", displayed_wave(g), g.wave_count), x+28, y, 20, rl.RAYWHITE)
	remaining := waves_remaining(g)
	remaining_label := "waves left"
	if remaining == 1 { remaining_label = "wave left" }
	draw_text(fmt.tprintf("%d %s", remaining, remaining_label), x+28, y+21, 14, rl.LIGHTGRAY)
	draw_button(x+154, 78, 66, 34, "Menu", false)

	draw_tower_button(g, x, 126, .Arrow, "1  Arrow", g.selected_tower_type == .Arrow)
	draw_tower_button(g, x, 176, .Cannon, "2  Cannon", g.selected_tower_type == .Cannon)
	draw_tower_button(g, x, 226, .Frost, "3  Frost", g.selected_tower_type == .Frost)
	draw_tower_button(g, x, 276, .Flame, "4  Flame", g.selected_tower_type == .Flame)

	wave_button_label := "Space - Start Wave"
	wave_button_disabled := g.wave_state != .Waiting || g.mode != .Playing
	if g.wave_state == .Spawning { wave_button_label = "Wave Spawning" }
	if g.wave_state == .Clearing { wave_button_label = "Enemies Remaining" }
	if g.wave_state == .Finished { wave_button_label = "All Waves Cleared" }
	if g.mode == .Paused { wave_button_label = "Game Paused" }
	draw_button_disabled(x, 326, 220, 42, wave_button_label, false, wave_button_disabled)

	draw_text(fmt.tprintf("Speed: %.0fx", g.game_speed), x, 380, 20, rl.RAYWHITE)
	draw_button_disabled(x+134,374,38,32,"-",false,g.game_speed <= 1)
	draw_button_disabled(x+182,374,38,32,"+",false,g.game_speed >= 3)

	if g.selected_tower_index >= 0 && g.selected_tower_index < g.tower_count {
		t := &g.towers[g.selected_tower_index]
		def := get_tower_def(t.kind)

		draw_text("Selected Tower", x, 416, 22, rl.RAYWHITE)
		draw_text(fmt.tprintf("%s L%d", def.name, t.level), x, 444, 20, rl.GOLD)

		upgrade := upgrade_cost(t, def)
		draw_button(x, 472, 108, 38, fmt.tprintf("U  $%d", upgrade), false)
		draw_button(x+116, 472, 104, 38, fmt.tprintf("S  $%d", int(f32(t.total_invested)*0.70)), false)

		draw_text(def.role, x, 522, 16, rl.LIGHTGRAY)
		draw_text(fmt.tprintf("Damage: %.1f  Range: %.0f", tower_damage(t, def), tower_range(t, def)), x, 546, 17, rl.RAYWHITE)
		draw_text(fmt.tprintf("Type: %s", damage_type_name(def.damage_type)), x, 568, 17, rl.RAYWHITE)
		if def.slow_amount > 0 { draw_text(fmt.tprintf("Slow: %.0f%%", def.slow_amount*100), x, 590, 16, rl.SKYBLUE) }
		if def.burn_damage > 0 { draw_text(fmt.tprintf("Burn: %.1f / tick", tower_burn_damage(t,def)), x, 590, 16, rl.ORANGE) }
	}

	preview_index := g.current_wave
	if g.wave_state == .Spawning || g.wave_state == .Clearing { preview_index += 1 }
	if preview_index < g.wave_count {
		wave := g.waves[preview_index]
		edef := get_enemy_def(wave.enemy_type)
		draw_text("NEXT WAVE", x, 612, 16, rl.GOLD)
		draw_asset(&g.assets, edef.asset, vec2(f32(x+20),650), vec2(34,34), 0, rl.WHITE)
		draw_text(fmt.tprintf("%s  x%d", edef.name, wave.count), x+44, 635, 18, rl.RAYWHITE)
		draw_text(edef.resistance, x+44, 657, 13, rl.LIGHTGRAY)
	}

	if g.wave_state == .Waiting {
		draw_text("State: Waiting", x, 690, 16, rl.LIGHTGRAY)
	} else if g.wave_state == .Spawning {
		draw_text("State: Spawning", x, 690, 16, rl.LIGHTGRAY)
	} else if g.wave_state == .Clearing {
		draw_text("State: Clearing", x, 690, 16, rl.LIGHTGRAY)
	} else if g.wave_state == .Finished {
		draw_text("State: Finished", x, 690, 16, rl.LIGHTGRAY)
	}
}

draw_icon_or_glyph :: proc(g: ^Game, id: Asset_Id, pos: Vec2, color: rl.Color) {
	if !draw_asset(&g.assets,id,pos,vec2(20,20),0,rl.WHITE) { rl.DrawCircleV(pos,7,color) }
}

draw_tower_button :: proc(g: ^Game, x,y: int, kind: Tower_Type, label: string, selected: bool) {
	def := get_tower_def(kind)
	draw_button(x,y,220,42,fmt.tprintf("%s   $%d",label,def.cost),selected)
	draw_asset(&g.assets,def.asset,vec2(f32(x+196),f32(y+21)),vec2(30,30),0,rl.WHITE)
	if g.gold < def.cost { rl.DrawRectangle(i32(x),i32(y),220,42,rl.Color{18,18,20,125}) }
}

damage_type_name :: proc(kind: Damage_Type) -> string {
	switch kind { case .Physical: return "Physical"; case .Magic: return "Magic"; case .Elemental: return "Elemental" }
	return ""
}

draw_button :: proc(x, y, w, h: int, label: string, selected: bool) {
	draw_button_disabled(x,y,w,h,label,selected,false)
}

draw_button_disabled :: proc(x, y, w, h: int, label: string, selected, disabled: bool) {
	color := rl.Color{70, 70, 78, 255}
	mouse := screen_to_game_pos(rl.GetMousePosition())
	if point_in_rect(mouse,x,y,w,h) && !disabled { color = rl.Color{88,82,82,255} }
	if selected {
		color = rl.Color{105, 105, 135, 255}
	}
	if disabled { color = rl.Color{45,45,50,255} }

	rl.DrawRectangle(i32(x), i32(y), i32(w), i32(h), color)
	rl.DrawRectangleLines(i32(x), i32(y), i32(w), i32(h), rl.RAYWHITE)
	text_color := rl.RAYWHITE
	if disabled { text_color = rl.GRAY }
	draw_text(label, x+12, y+(h-18)/2, 18, text_color)
}

draw_center_message :: proc(text: string, color: rl.Color) {
	rl.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, rl.Color{0, 0, 0, 120})

	text_c := fmt.ctprintf("%s", text)
	text_width := int(rl.MeasureText(text_c, 56))
	draw_text(text, SCREEN_WIDTH/2-text_width/2, SCREEN_HEIGHT/2-30, 56, color)
}

draw_run_stats :: proc(g: ^Game, center_x, y: int) {
	lines := [4]string {
		fmt.tprintf("Waves cleared: %d / %d", waves_cleared(g), g.wave_count),
		fmt.tprintf("Enemies defeated: %d", g.enemies_defeated),
		fmt.tprintf("Enemies leaked: %d", g.enemies_leaked),
		fmt.tprintf("Lives: %d    Gold: %d", max(g.lives, 0), g.gold),
	}
	for line, index in lines {
		line_c := fmt.ctprintf("%s", line)
		width := int(rl.MeasureText(line_c, 20))
		draw_text(line, center_x-width/2, y+index*27, 20, rl.RAYWHITE)
	}
}

draw_result_message :: proc(g: ^Game, title, action: string, color: rl.Color) {
	rl.DrawRectangle(0,0,SCREEN_WIDTH,SCREEN_HEIGHT,rl.Color{0,0,0,150})
	title_c := fmt.ctprintf("%s",title)
	title_width := int(rl.MeasureText(title_c,48))
	draw_text(title,SCREEN_WIDTH/2-title_width/2,230,48,color)
	draw_run_stats(g, SCREEN_WIDTH/2, 300)
	if action == "" { return }
	draw_button(520,440,240,48,fmt.tprintf("%s  [Enter]",action),false)
}

draw_pause_message :: proc(g: ^Game) {
	rl.DrawRectangle(0,0,SCREEN_WIDTH,SCREEN_HEIGHT,rl.Color{0,0,0,165})
	if g.restart_confirmation {
		draw_text("RESTART THIS LEVEL?", 438, 300, 36, rl.GOLD)
		draw_text("Current progress will be lost.", 493, 355, 20, rl.RAYWHITE)
		draw_button(490,410,140,46,"Confirm",false)
		draw_button(650,410,140,46,"Cancel",false)
		return
	}
	draw_text("MENU", 584, 255, 42, rl.RAYWHITE)
	draw_button(520,320,240,46,"Resume  [Esc]",false)
	draw_button(520,380,240,46,"Restart Level  [R]",false)
	draw_button(520,440,240,46,"Quit  [Q]",false)
}
