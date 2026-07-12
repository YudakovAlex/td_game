package main

import "core:testing"

@(test)
test_route_tiles_store_straight_and_corner_connections :: proc(t: ^testing.T) {
	g := Game{}
	g.levels[0].route_count = 1
	route := Path_Route{}
	route.points[0] = vec2(20, 100)
	route.points[1] = vec2(100, 100)
	route.points[2] = vec2(100, 180)
	route.point_count = 3
	g.levels[0].routes[0] = route
	init_map(&g)

	testing.expect(t, g.tiles[2][0].connections == ROUTE_EAST)
	testing.expect(t, g.tiles[2][1].connections == ROUTE_EAST|ROUTE_WEST)
	testing.expect(t, g.tiles[2][2].connections == ROUTE_SOUTH|ROUTE_WEST)
	testing.expect(t, g.tiles[3][2].connections == ROUTE_NORTH|ROUTE_SOUTH)
	testing.expect(t, g.tiles[4][2].connections == ROUTE_NORTH)
	testing.expect(t, g.tiles[2][0].kind == .Spawn)
	testing.expect(t, g.tiles[4][2].kind == .Exit)
}

@(test)
test_route_tiles_merge_connections_for_multiple_routes :: proc(t: ^testing.T) {
	g := Game{}
	g.levels[0].route_count = 2

	horizontal := Path_Route{}
	horizontal.points[0] = vec2(20, 100)
	horizontal.points[1] = vec2(180, 100)
	horizontal.point_count = 2
	g.levels[0].routes[0] = horizontal

	vertical := Path_Route{}
	vertical.points[0] = vec2(100, 20)
	vertical.points[1] = vec2(100, 180)
	vertical.point_count = 2
	g.levels[0].routes[1] = vertical
	init_map(&g)

	all_directions := ROUTE_NORTH|ROUTE_EAST|ROUTE_SOUTH|ROUTE_WEST
	testing.expect(t, g.tiles[2][2].connections == all_directions)
	asset, rotation := road_asset_for_connections(ROUTE_EAST|ROUTE_WEST)
	testing.expect(t, asset == .Path)
	testing.expect(t, rotation == 90)
}

@(test)
test_corner_road_asset_rotations :: proc(t: ^testing.T) {
	asset, rotation := road_asset_for_connections(ROUTE_SOUTH|ROUTE_EAST)
	testing.expect(t, asset == .Path_Turn)
	testing.expect(t, rotation == 0)

	asset, rotation = road_asset_for_connections(ROUTE_SOUTH|ROUTE_WEST)
	testing.expect(t, asset == .Path_Turn)
	testing.expect(t, rotation == 90)

	asset, rotation = road_asset_for_connections(ROUTE_NORTH|ROUTE_WEST)
	testing.expect(t, asset == .Path_Turn)
	testing.expect(t, rotation == 180)

	asset, rotation = road_asset_for_connections(ROUTE_NORTH|ROUTE_EAST)
	testing.expect(t, asset == .Path_Turn)
	testing.expect(t, rotation == 270)
}

@(test)
test_ruined_outskirts_route_stays_on_authored_segments :: proc(t: ^testing.T) {
	route := Path_Route{}
	route.points[0] = vec2(20, 380)
	route.points[1] = vec2(180, 380)
	route.points[2] = vec2(180, 140)
	route.points[3] = vec2(420, 140)
	route.points[4] = vec2(420, 580)
	route.points[5] = vec2(700, 580)
	route.points[6] = vec2(700, 300)
	route.points[7] = vec2(940, 300)
	route.point_count = 8

	e := Enemy{pos = route.points[0], path_index = 1, alive = true}
	advance_enemy_on_route(&e, &route, 200)
	testing.expect(t, e.pos == vec2(180, 340))
	testing.expect(t, e.path_index == 2)

	advance_enemy_on_route(&e, &route, 300)
	testing.expect(t, e.pos == vec2(280, 140))
	testing.expect(t, e.path_index == 3)
}
