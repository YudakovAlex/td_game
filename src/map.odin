package main

import rl "vendor:raylib"

ROUTE_NORTH :: u8(1)
ROUTE_EAST  :: u8(2)
ROUTE_SOUTH :: u8(4)
ROUTE_WEST  :: u8(8)

road_asset_for_connections :: proc(connections: u8) -> (Asset_Id, f32) {
	switch connections {
	case ROUTE_NORTH | ROUTE_SOUTH:
		return .Path, 0
	case ROUTE_EAST | ROUTE_WEST:
		return .Path, 90
	case ROUTE_SOUTH | ROUTE_EAST:
		return .Path_Turn, 0
	case ROUTE_SOUTH | ROUTE_WEST:
		return .Path_Turn, 90
	case ROUTE_NORTH | ROUTE_WEST:
		return .Path_Turn, 180
	case ROUTE_NORTH | ROUTE_EAST:
		return .Path_Turn, 270
	}
	return .Path, 0
}

grasslands_road_asset_for_connections :: proc(connections: u8) -> (Grasslands_Asset_Id, f32) {
	switch connections {
	case ROUTE_NORTH | ROUTE_SOUTH:
		return .Road_Straight, 0
	case ROUTE_EAST | ROUTE_WEST:
		return .Road_Straight, 90
	case ROUTE_SOUTH | ROUTE_EAST:
		return .Road_Corner, 0
	case ROUTE_SOUTH | ROUTE_WEST:
		return .Road_Corner, 90
	case ROUTE_NORTH | ROUTE_WEST:
		return .Road_Corner, 180
	case ROUTE_NORTH | ROUTE_EAST:
		return .Road_Corner, 270
	}
	return .Road_Straight, 0
}

grasslands_decoration_at :: proc(level: ^Level_Def, tile_x, tile_y: int) -> (Map_Decoration, bool) {
	for i := 0; i < level.decoration_count; i += 1 {
		decoration := level.decorations[i]
		if decoration.tile_x == tile_x && decoration.tile_y == tile_y {
			return decoration, true
		}
	}
	return Map_Decoration{}, false
}

road_color_for_level :: proc(level_name: string) -> rl.Color {
	if level_name == "Ruined Outskirts" { return rl.Color{92,75,66,255} }
	return rl.BROWN
}

route_connections_for_level :: proc(level: ^Level_Def) -> [MAP_H][MAP_W]u8 {
	connections := [MAP_H][MAP_W]u8{}
	for route_index := 0; route_index < level.route_count; route_index += 1 {
		route := &level.routes[route_index]
		for i := 0; i < route.point_count-1; i += 1 {
			a := route.points[i]
			b := route.points[i+1]
			ax, ay := int(a.x)/TILE_SIZE, int(a.y)/TILE_SIZE
			bx, by := int(b.x)/TILE_SIZE, int(b.y)/TILE_SIZE
			if ax == bx {
				min_y, max_y := ay, by
				if min_y > max_y { min_y, max_y = max_y, min_y }
				for y := min_y; y <= max_y; y += 1 {
					if ax >= 0 && ax < MAP_W && y >= 0 && y < MAP_H {
						if y > min_y { connections[y][ax] |= ROUTE_NORTH }
						if y < max_y { connections[y][ax] |= ROUTE_SOUTH }
					}
				}
			} else if ay == by {
				min_x, max_x := ax, bx
				if min_x > max_x { min_x, max_x = max_x, min_x }
				for x := min_x; x <= max_x; x += 1 {
					if x >= 0 && x < MAP_W && ay >= 0 && ay < MAP_H {
						if x < max_x { connections[ay][x] |= ROUTE_EAST }
						if x > min_x { connections[ay][x] |= ROUTE_WEST }
					}
				}
			}
		}
	}
	return connections
}

draw_road_connectors :: proc(center: Vec2, connections: u8, color: rl.Color) {
	for direction in 0..<4 {
		bit := u8(1 << u8(direction))
		if (connections & bit) == 0 { continue }

		offset := Vec2{}
		switch bit {
		case ROUTE_NORTH: offset = vec2(0, -f32(TILE_SIZE/2))
		case ROUTE_EAST:  offset = vec2(f32(TILE_SIZE/2), 0)
		case ROUTE_SOUTH: offset = vec2(0, f32(TILE_SIZE/2))
		case ROUTE_WEST:  offset = vec2(-f32(TILE_SIZE/2), 0)
		}
		rl.DrawLineEx(center, v_add(center, offset), 6, color)
	}
	rl.DrawCircleV(center, 3, color)
}

mark_route_tiles :: proc(g: ^Game, route: ^Path_Route) {
	for i := 0; i < route.point_count-1; i += 1 {
		a := route.points[i]
		b := route.points[i+1]
		ax, ay := int(a.x)/TILE_SIZE, int(a.y)/TILE_SIZE
		bx, by := int(b.x)/TILE_SIZE, int(b.y)/TILE_SIZE
		if ax == bx {
			min_y, max_y := ay, by
			if min_y > max_y { min_y, max_y = max_y, min_y }
			for y := min_y; y <= max_y; y += 1 {
				if ax >= 0 && ax < MAP_W && y >= 0 && y < MAP_H {
					g.tiles[y][ax].kind = .Path
					if y > min_y { g.tiles[y][ax].connections |= ROUTE_NORTH }
					if y < max_y { g.tiles[y][ax].connections |= ROUTE_SOUTH }
				}
			}
		} else if ay == by {
			min_x, max_x := ax, bx
			if min_x > max_x { min_x, max_x = max_x, min_x }
			for x := min_x; x <= max_x; x += 1 {
				if x >= 0 && x < MAP_W && ay >= 0 && ay < MAP_H {
					g.tiles[ay][x].kind = .Path
					if x < max_x { g.tiles[ay][x].connections |= ROUTE_EAST }
					if x > min_x { g.tiles[ay][x].connections |= ROUTE_WEST }
				}
			}
		}
	}
	start := route.points[0]
	finish := route.points[route.point_count-1]
	g.tiles[int(start.y)/TILE_SIZE][int(start.x)/TILE_SIZE].kind = .Spawn
	g.tiles[int(finish.y)/TILE_SIZE][int(finish.x)/TILE_SIZE].kind = .Exit
}

init_map :: proc(g: ^Game) {
	for y := 0; y < MAP_H; y += 1 {
		for x := 0; x < MAP_W; x += 1 {
			g.tiles[y][x].kind = .Buildable
			g.tiles[y][x].connections = 0
		}
	}
	level := &g.levels[g.current_level]
	for i := 0; i < level.route_count; i += 1 { mark_route_tiles(g, &level.routes[i]) }
}

draw_grasslands_map :: proc(g: ^Game) {
	level := &g.levels[g.current_level]
	path_color := rl.Color{155,118,69,255}
	for y := 0; y < MAP_H; y += 1 {
		for x := 0; x < MAP_W; x += 1 {
			tile := g.tiles[y][x]
			color := rl.Color{120,170,100,255}
			switch tile.kind {
			case .Buildable: color = rl.Color{120,170,100,255}
			case .Path: color = rl.Color{165,130,80,255}
			case .Spawn: color = rl.Color{80,100,220,255}
			case .Exit: color = rl.Color{220,80,80,255}
			case .Blocked: color = rl.DARKGRAY
			}
			rl.DrawRectangle(i32(x*TILE_SIZE), i32(y*TILE_SIZE), TILE_SIZE, TILE_SIZE, color)

			decoration, has_decoration := grasslands_decoration_at(level, x, y)
			asset := Grasslands_Asset_Id.Base
			rotation: f32 = 0
			if tile.kind == .Path {
				asset, rotation = grasslands_road_asset_for_connections(tile.connections)
			}
			if tile.kind == .Spawn { asset = .Spawn }
			if tile.kind == .Exit { asset = .Exit }
			if has_decoration && grasslands_asset_is_route_variant(decoration.asset) {
				asset = decoration.asset
				if tile.connections == ROUTE_EAST|ROUTE_WEST { rotation = 90 }
			}

			if tile.kind == .Path || tile.kind == .Spawn || tile.kind == .Exit {
				draw_road_connectors(tile_center(x,y), tile.connections, path_color)
			}
			draw_grasslands_asset(&g.assets, asset, tile_center(x,y), vec2(TILE_SIZE,TILE_SIZE), rotation, rl.WHITE)

			if has_decoration && grasslands_asset_is_landmark(decoration.asset) {
				draw_grasslands_asset(&g.assets, decoration.asset, tile_center(x,y), vec2(TILE_SIZE,TILE_SIZE), 0, rl.WHITE)
			}
			rl.DrawRectangleLines(i32(x*TILE_SIZE), i32(y*TILE_SIZE), TILE_SIZE, TILE_SIZE, rl.Color{0,0,0,35})
		}
	}
}

draw_map :: proc(g: ^Game) {
	if g.levels[g.current_level].terrain == .Grasslands {
		draw_grasslands_map(g)
		return
	}
	ruin_style := g.levels[g.current_level].name == "Ruined Outskirts"
	path_color := road_color_for_level(g.levels[g.current_level].name)
	for y := 0; y < MAP_H; y += 1 {
		for x := 0; x < MAP_W; x += 1 {
			tile := g.tiles[y][x]
			color := rl.LIGHTGRAY
			switch tile.kind {
			case .Buildable: color = rl.Color{120,170,100,255}; if ruin_style { color = rl.Color{94,105,86,255} }
			case .Path: color = rl.Color{165,130,80,255}; if ruin_style { color = rl.Color{112,99,84,255} }
			case .Spawn: color = rl.Color{80,100,220,255}
			case .Exit: color = rl.Color{220,80,80,255}
			case .Blocked: color = rl.DARKGRAY; if ruin_style { color = rl.Color{58,59,56,255} }
			}
			rl.DrawRectangle(i32(x*TILE_SIZE),i32(y*TILE_SIZE),TILE_SIZE,TILE_SIZE,color)
			asset := Asset_Id.Grass
			rotation: f32 = 0
			if tile.kind == .Path { asset, rotation = road_asset_for_connections(tile.connections) }
			if tile.kind == .Spawn { asset = .Spawn }
			if tile.kind == .Exit { asset = .Exit }
			tint := rl.WHITE
			if ruin_style && tile.kind == .Buildable { tint = rl.Color{180,185,170,255} }
			if ruin_style && tile.kind == .Path { tint = rl.Color{185,175,155,255} }
			draw_asset(&g.assets,asset,tile_center(x,y),vec2(TILE_SIZE,TILE_SIZE),rotation,tint)
			if tile.kind == .Path || tile.kind == .Spawn || tile.kind == .Exit {
				draw_road_connectors(tile_center(x,y), tile.connections, path_color)
			}
			h := (x*37+y*71+x*y*11)%29
			if tile.kind == .Buildable && ruin_style && h == 5 {
				stone := v_add(tile_center(x,y),vec2(-11,10))
				rl.DrawRectangle(i32(stone.x), i32(stone.y), 11, 6, rl.Color{55,57,52,155})
				rl.DrawRectangle(i32(stone.x+8), i32(stone.y-4), 8, 5, rl.Color{75,73,64,175})
			} else if tile.kind == .Buildable && ruin_style && h == 13 {
				rl.DrawLineEx(v_add(tile_center(x,y),vec2(12,-12)), v_add(tile_center(x,y),vec2(12,8)), 4, rl.Color{61,61,55,140})
				rl.DrawLineEx(v_add(tile_center(x,y),vec2(16,-9)), v_add(tile_center(x,y),vec2(16,4)), 3, rl.Color{72,68,57,150})
			} else if tile.kind == .Buildable && h == 3 {
				rl.DrawCircleV(v_add(tile_center(x,y),vec2(11,9)),4,rl.Color{68,94,58,180})
				rl.DrawCircleV(v_add(tile_center(x,y),vec2(8,6)),3,rl.Color{105,126,78,210})
			} else if tile.kind == .Buildable && h == 11 {
				rl.DrawPoly(v_add(tile_center(x,y),vec2(-12,11)),5,4,0,rl.Color{92,88,78,190})
			}
			rl.DrawRectangleLines(i32(x*TILE_SIZE),i32(y*TILE_SIZE),TILE_SIZE,TILE_SIZE,rl.Color{0,0,0,35})
		}
	}
}

draw_build_preview :: proc(g: ^Game) {
	if g.selected_tower_type == .None { return }
	mouse := screen_to_game_pos(rl.GetMousePosition())
	if mouse.x < 0 || mouse.x >= f32(UI_X) || mouse.y < 0 || mouse.y >= f32(MAP_H*TILE_SIZE) { return }
	tx, ty := screen_to_tile(mouse)
	valid := g.tiles[ty][tx].kind == .Buildable && tower_at_tile(g,tx,ty) < 0
	def := get_tower_def(g, g.selected_tower_type)
	affordable := TESTER_MODE || g.gold >= def.cost
	c := rl.Color{70,210,105,100}
	if !valid { c = rl.Color{220,70,65,120} } else if !affordable { c = rl.Color{230,165,55,120} }
	center := tile_center(tx,ty)
	range_color := rl.Color{55,110,210,28}
	line_color := rl.SKYBLUE
	if !valid { range_color = rl.Color{210,65,65,24}; line_color = rl.Color{235,100,90,210} }
	rl.DrawCircleV(center,def.range,range_color)
	rl.DrawCircleLines(i32(center.x),i32(center.y),def.range,line_color)
	rl.DrawRectangle(i32(tx*TILE_SIZE),i32(ty*TILE_SIZE),TILE_SIZE,TILE_SIZE,c)
	draw_asset(&g.assets,def.asset,center,vec2(38,38),0,rl.Color{255,255,255,155})
}

draw_path :: proc(g: ^Game) {
	if g.levels[g.current_level].terrain == .Grasslands {
		return
	}
	level := &g.levels[g.current_level]
	path_color := road_color_for_level(level.name)
	for route_index := 0; route_index < level.route_count; route_index += 1 {
		route := &level.routes[route_index]
		for i := 0; i < route.point_count-1; i += 1 {
			rl.DrawLineEx(route.points[i],route.points[i+1],5,path_color)
		}
	}
}
