package main

import "core:testing"

@(test)
test_tower_target_modes :: proc(t: ^testing.T) {
	g := Game{}
	g.enemy_count = 5
	g.enemies[0] = Enemy{pos = Vec2{20, 0}, hp = 50, path_index = 2, alive = true}
	g.enemies[1] = Enemy{pos = Vec2{40, 0}, hp = 100, path_index = 5, alive = true}
	g.enemies[2] = Enemy{pos = Vec2{60, 0}, hp = 10, path_index = 3, alive = true}
	g.enemies[3] = Enemy{pos = Vec2{20, 0}, hp = 1, path_index = 9, alive = false}
	g.enemies[4] = Enemy{pos = Vec2{200, 0}, hp = 1, path_index = 10, alive = true}

	def := Tower_Def{range = 100}
	tower := Tower{pos = Vec2{0, 0}}

	testing.expect(t, tower.target_mode == .First)
	testing.expect(t, find_tower_target(&g, &tower, def) == 1)

	tower.target_mode = .Weakest
	testing.expect(t, find_tower_target(&g, &tower, def) == 2)

	tower.target_mode = .Strongest
	testing.expect(t, find_tower_target(&g, &tower, def) == 1)
}

@(test)
test_tower_target_ties_are_deterministic :: proc(t: ^testing.T) {
	g := Game{}
	g.enemy_count = 3
	g.enemies[0] = Enemy{pos = Vec2{20, 0}, hp = 100, path_index = 4, alive = true}
	g.enemies[1] = Enemy{pos = Vec2{40, 0}, hp = 100, path_index = 4, alive = true}
	g.enemies[2] = Enemy{pos = Vec2{60, 0}, hp = 100, path_index = 3, alive = true}

	def := Tower_Def{range = 100}
	tower := Tower{pos = Vec2{0, 0}, target_mode = .First}
	testing.expect(t, find_tower_target(&g, &tower, def) == 0)

	tower.target_mode = .Weakest
	testing.expect(t, find_tower_target(&g, &tower, def) == 0)

	tower.target_mode = .Strongest
	testing.expect(t, find_tower_target(&g, &tower, def) == 0)
}

@(test)
test_target_mode_cycle :: proc(t: ^testing.T) {
	testing.expect(t, next_target_mode(.First) == .Weakest)
	testing.expect(t, next_target_mode(.Weakest) == .Strongest)
	testing.expect(t, next_target_mode(.Strongest) == .First)

	g := Game{}
	g.tower_count = 1
	g.towers[0].target_mode = .First
	cycle_tower_target_mode(&g, 0)
	testing.expect(t, g.towers[0].target_mode == .Weakest)
	cycle_tower_target_mode(&g, 0)
	testing.expect(t, g.towers[0].target_mode == .Strongest)
	cycle_tower_target_mode(&g, 0)
	testing.expect(t, g.towers[0].target_mode == .First)
}

@(test)
test_tower_cooldown_by_level :: proc(t: ^testing.T) {
	def := Tower_Def{cooldown = 1.0}
	tower := Tower{level = 1}
	testing.expect(t, tower_cooldown(&tower, def) == 1.0)

	tower.level = 2
	testing.expect(t, tower_cooldown(&tower, def) == 1.0)

	tower.level = 3
	testing.expect(t, tower_cooldown(&tower, def) == 0.82)
}
