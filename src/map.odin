package main

import rl "vendor:raylib"

PATH_POINTS := [?]Vec2 {
	{20, 300},
	{180, 300},
	{180, 100},
	{420, 100},
	{420, 500},
	{700, 500},
	{700, 220},
	{920, 220},
}

init_map :: proc(g: ^Game) {
	for y := 0; y < MAP_H; y += 1 {
		for x := 0; x < MAP_W; x += 1 {
			g.tiles[y][x].kind = .Buildable
		}
	}

	for i := 0; i < len(PATH_POINTS)-1; i += 1 {
		a := PATH_POINTS[i]
		b := PATH_POINTS[i+1]

		ax := int(a.x) / TILE_SIZE
		ay := int(a.y) / TILE_SIZE
		bx := int(b.x) / TILE_SIZE
		by := int(b.y) / TILE_SIZE

		if ax == bx {
			min_y := ay
			max_y := by
			if min_y > max_y {
				tmp := min_y
				min_y = max_y
				max_y = tmp
			}

			for y := min_y; y <= max_y; y += 1 {
				if ax >= 0 && ax < MAP_W && y >= 0 && y < MAP_H {
					g.tiles[y][ax].kind = .Path
				}
			}
		} else if ay == by {
			min_x := ax
			max_x := bx
			if min_x > max_x {
				tmp := min_x
				min_x = max_x
				max_x = tmp
			}

			for x := min_x; x <= max_x; x += 1 {
				if x >= 0 && x < MAP_W && ay >= 0 && ay < MAP_H {
					g.tiles[ay][x].kind = .Path
				}
			}
		}
	}

	sx := int(PATH_POINTS[0].x) / TILE_SIZE
	sy := int(PATH_POINTS[0].y) / TILE_SIZE
	ex := int(PATH_POINTS[len(PATH_POINTS)-1].x) / TILE_SIZE
	ey := int(PATH_POINTS[len(PATH_POINTS)-1].y) / TILE_SIZE

	g.tiles[sy][sx].kind = .Spawn
	g.tiles[ey][ex].kind = .Exit
}

draw_map :: proc(g: ^Game) {
	for y := 0; y < MAP_H; y += 1 {
		for x := 0; x < MAP_W; x += 1 {
			tile := g.tiles[y][x]

			color := rl.LIGHTGRAY
			switch tile.kind {
			case .Buildable:
				color = rl.Color{120, 170, 100, 255}
			case .Path:
				color = rl.Color{165, 130, 80, 255}
			case .Spawn:
				color = rl.Color{80, 100, 220, 255}
			case .Exit:
				color = rl.Color{220, 80, 80, 255}
			case .Blocked:
				color = rl.DARKGRAY
			}

			rl.DrawRectangle(
				i32(x*TILE_SIZE),
				i32(y*TILE_SIZE),
				i32(TILE_SIZE),
				i32(TILE_SIZE),
				color,
			)

			asset := Asset_Id.Grass
			if tile.kind == .Path { asset = .Path }
			if tile.kind == .Spawn { asset = .Spawn }
			if tile.kind == .Exit { asset = .Exit }
			draw_asset(&g.assets, asset, tile_center(x,y), vec2(TILE_SIZE,TILE_SIZE), 0, rl.WHITE)

			// Stable coordinate hash keeps decoration deterministic and off the road.
			h := (x*37+y*71+x*y*11)%29
			if tile.kind == .Buildable && h == 3 {
				rl.DrawCircleV(v_add(tile_center(x,y), vec2(11,9)), 4, rl.Color{68,94,58,180})
				rl.DrawCircleV(v_add(tile_center(x,y), vec2(8,6)), 3, rl.Color{105,126,78,210})
			} else if tile.kind == .Buildable && h == 11 {
				rl.DrawPoly(v_add(tile_center(x,y), vec2(-12,11)), 5, 4, 0, rl.Color{92,88,78,190})
			}

			rl.DrawRectangleLines(
				i32(x*TILE_SIZE),
				i32(y*TILE_SIZE),
				i32(TILE_SIZE),
				i32(TILE_SIZE),
				rl.Color{0, 0, 0, 35},
			)
		}
	}
}

draw_build_preview :: proc(g: ^Game) {
	if g.selected_tower_type == .None { return }
	mouse := screen_to_game_pos(rl.GetMousePosition())
	if mouse.x < 0 || mouse.x >= f32(UI_X) || mouse.y < 0 || mouse.y >= f32(MAP_H*TILE_SIZE) { return }
	tx, ty := screen_to_tile(mouse)
	valid := g.tiles[ty][tx].kind == .Buildable && tower_at_tile(g,tx,ty) < 0
	def := get_tower_def(g.selected_tower_type)
	affordable := g.gold >= def.cost
	c := rl.Color{70,210,105,100}
	if !valid { c = rl.Color{220,70,65,120} } else if !affordable { c = rl.Color{230,165,55,120} }
	rl.DrawRectangle(i32(tx*TILE_SIZE),i32(ty*TILE_SIZE),TILE_SIZE,TILE_SIZE,c)
	draw_asset(&g.assets, def.asset, tile_center(tx,ty), vec2(38,38), 0, rl.Color{255,255,255,155})
}

draw_path :: proc() {
	for i := 0; i < len(PATH_POINTS)-1; i += 1 {
		rl.DrawLineEx(PATH_POINTS[i], PATH_POINTS[i+1], 5, rl.BROWN)
	}
}
