package main

import "core:testing"
import "core:strings"

@(test)
test_content_files_load_current_definitions :: proc(t: ^testing.T) {
	g := Game{}
	init_levels(&g)
	defer unload_level_content(&g.levels)
	defer unload_content(&g.content)
	testing.expect(t, load_content(&g))
	testing.expect(t, g.content.towers[int(Tower_Type.Arrow)].cost == 50)
	testing.expect(t, g.content.towers[int(Tower_Type.Flame)].burn_damage == 5)
	testing.expect(t, g.content.enemies[int(Enemy_Type.Armored)].physical_multiplier == 0.65)
	testing.expect(t, g.content.enemies[int(Enemy_Type.Armored)].magic_multiplier == 1.35)
	testing.expect(t, g.levels[0].wave_count == 15)
	testing.expect(t, g.levels[0].waves[5].group_count == 2)
	testing.expect(t, g.levels[0].waves[5].groups[0].enemy_type == .Runner)
	testing.expect(t, g.levels[0].name == "Grasslands")
	testing.expect(t, g.levels[0].starting_gold == 200)
	testing.expect(t, g.levels[0].route_count == 1)
	testing.expect(t, g.levels[0].routes[0].point_count == 8)
	testing.expect(t, g.levels[1].route_count == 2)
	testing.expect(t, g.levels[1].routes[0].point_count == 8)
	testing.expect(t, g.levels[1].routes[1].point_count == 8)
	testing.expect(t, g.levels[2].route_count == 1)
	testing.expect(t, g.levels[2].routes[0].point_count == 10)
}

@(test)
test_grasslands_content_curve :: proc(t: ^testing.T) {
	g := Game{}
	init_levels(&g)
	defer unload_level_content(&g.levels)
	defer unload_content(&g.content)
	testing.expect(t, load_content(&g))

	grasslands := &g.levels[0]
	testing.expect(t, grasslands.wave_count == 15)

	// The opening waves introduce the basic enemy roles in sequence.
	testing.expect(t, grasslands.waves[0].groups[0].enemy_type == .Grunt)
	testing.expect(t, grasslands.waves[2].groups[0].enemy_type == .Runner)
	testing.expect(t, grasslands.waves[4].groups[0].enemy_type == .Brute)

	// Armored enemies arrive only after the basic roles are established.
	for wave_index := 0; wave_index < 10; wave_index += 1 {
		wave := grasslands.waves[wave_index]
		for group_index := 0; group_index < wave.group_count; group_index += 1 {
			testing.expect(t, wave.groups[group_index].enemy_type != .Armored)
		}
	}
	testing.expect(t, grasslands.waves[10].groups[0].enemy_type == .Armored)

	// Boss waves remain explicit milestones in the level curve.
	testing.expect(t, grasslands.waves[9].group_count == 1)
	testing.expect(t, grasslands.waves[9].groups[0].enemy_type == .Boss)
	testing.expect(t, grasslands.waves[14].group_count == 1)
	testing.expect(t, grasslands.waves[14].groups[0].enemy_type == .Boss)
}

@(test)
test_grasslands_mixed_wave_roles :: proc(t: ^testing.T) {
	g := Game{}
	init_levels(&g)
	defer unload_level_content(&g.levels)
	defer unload_content(&g.content)
	testing.expect(t, load_content(&g))

	grasslands := &g.levels[0]
	expected_first := [4]Enemy_Type{.Runner, .Brute, .Armored, .Runner}
	expected_second := [4]Enemy_Type{.Grunt, .Runner, .Grunt, .Armored}
	mixed_wave_indices := [4]int{5, 7, 10, 12}

	for i in 0..<len(mixed_wave_indices) {
		wave := grasslands.waves[mixed_wave_indices[i]]
		testing.expect(t, wave.group_count == 2)
		testing.expect(t, wave.groups[0].enemy_type == expected_first[i])
		testing.expect(t, wave.groups[1].enemy_type == expected_second[i])
		testing.expect(t, wave.groups[0].count > 0)
		testing.expect(t, wave.groups[1].count > 0)
	}
}

@(test)
test_tower_and_armored_matchups_remain_distinct :: proc(t: ^testing.T) {
	g := Game{}
	init_levels(&g)
	defer unload_level_content(&g.levels)
	defer unload_content(&g.content)
	testing.expect(t, load_content(&g))

	arrow := g.content.towers[int(Tower_Type.Arrow)]
	cannon := g.content.towers[int(Tower_Type.Cannon)]
	frost := g.content.towers[int(Tower_Type.Frost)]
	flame := g.content.towers[int(Tower_Type.Flame)]
	armored := g.content.enemies[int(Enemy_Type.Armored)]

	testing.expect(t, arrow.damage_type == .Physical)
	testing.expect(t, cannon.damage_type == .Physical && cannon.splash_radius > 0)
	testing.expect(t, frost.damage_type == .Magic && frost.slow_amount > 0)
	testing.expect(t, flame.damage_type == .Elemental && flame.splash_radius > 0 && flame.burn_damage > 0)
	testing.expect(t, armored.physical_multiplier < 1)
	testing.expect(t, armored.magic_multiplier > 1)
}

@(test)
test_map_parser_rejects_invalid_metadata_and_routes :: proc(t: ^testing.T) {
	valid := `{"version":1,"level":"test","name":"Test","starting_gold":1,"starting_lives":1,"routes":[{"points":[{"x":20,"y":20},{"x":60,"y":20}]}]}`
	level := Level_Def{}

	ok, _ := parse_map(valid, "test", &level)
	testing.expect(t, ok)
	delete(level.name)

	wrong_version := strings_replace(valid, `"version":1`, `"version":2`)
	ok, _ = parse_map(wrong_version, "test", &level)
	testing.expect(t, !ok)

	ok, _ = parse_map(valid, "other", &level)
	testing.expect(t, !ok)

	no_routes := strings_replace(valid, `"routes":[{"points":[{"x":20,"y":20},{"x":60,"y":20}]}]`, `"routes":[]`)
	ok, _ = parse_map(no_routes, "test", &level)
	testing.expect(t, !ok)

	one_point := strings_replace(valid, `{"x":20,"y":20},{"x":60,"y":20}`, `{"x":20,"y":20}`)
	ok, _ = parse_map(one_point, "test", &level)
	testing.expect(t, !ok)

	out_of_bounds := strings_replace(valid, `"x":20`, `"x":960`)
	ok, _ = parse_map(out_of_bounds, "test", &level)
	testing.expect(t, !ok)

	diagonal := strings_replace(valid, `{"x":60,"y":20}`, `{"x":60,"y":40}`)
	ok, _ = parse_map(diagonal, "test", &level)
	testing.expect(t, !ok)
}

@(test)
test_tower_parser_rejects_wrong_version_and_missing_entries :: proc(t: ^testing.T) {
	content := Content_Data{}
	valid, _ := parse_towers(`{"version": 2, "towers": []}`, &content)
	testing.expect(t, !valid)

	valid, _ = parse_towers(`{"version": 1, "towers": []}`, &content)
	testing.expect(t, !valid)
}

@(test)
test_tower_parser_rejects_duplicate_and_unknown_ids :: proc(t: ^testing.T) {
	content := Content_Data{}
	defer unload_content(&content)
	duplicate := `{"version":1,"towers":[
{"id":"arrow","name":"A","cost":1,"damage":1,"range":1,"cooldown":1,"projectile_speed":1,"splash_radius":0,"damage_type":"physical","slow_amount":0,"slow_duration":0,"burn_damage":0,"burn_duration":0,"asset":"tower_arrow","role":"A","color":[1,1,1,255]},
{"id":"arrow","name":"A","cost":1,"damage":1,"range":1,"cooldown":1,"projectile_speed":1,"splash_radius":0,"damage_type":"physical","slow_amount":0,"slow_duration":0,"burn_damage":0,"burn_duration":0,"asset":"tower_arrow","role":"A","color":[1,1,1,255]},
{"id":"frost","name":"F","cost":1,"damage":1,"range":1,"cooldown":1,"projectile_speed":1,"splash_radius":0,"damage_type":"magic","slow_amount":0,"slow_duration":0,"burn_damage":0,"burn_duration":0,"asset":"tower_frost","role":"F","color":[1,1,1,255]},
{"id":"flame","name":"L","cost":1,"damage":1,"range":1,"cooldown":1,"projectile_speed":1,"splash_radius":0,"damage_type":"elemental","slow_amount":0,"slow_duration":0,"burn_damage":0,"burn_duration":0,"asset":"tower_flame","role":"L","color":[1,1,1,255]}]}`
	valid, _ := parse_towers(duplicate, &content)
	testing.expect(t, !valid)
	unload_content(&content)

	unknown := strings_replace(duplicate, `"id":"arrow"`, `"id":"unknown"`)
	valid, _ = parse_towers(unknown, &content)
	testing.expect(t, !valid)
}

@(test)
test_wave_parser_rejects_unknown_enemy_and_group_overflow :: proc(t: ^testing.T) {
	level := Level_Def{}
	unknown := `{"version":1,"level":"test","waves":[{"groups":[{"enemy_id":"unknown","count":1,"spawn_interval":1,"hp_multiplier":1,"speed_multiplier":1}]}]}`
	valid, _ := parse_waves(unknown, "test", &level)
	testing.expect(t, !valid)

	overflow := `{"version":1,"level":"test","waves":[{"groups":[
{"enemy_id":"grunt","count":1,"spawn_interval":1,"hp_multiplier":1,"speed_multiplier":1},
{"enemy_id":"grunt","count":1,"spawn_interval":1,"hp_multiplier":1,"speed_multiplier":1},
{"enemy_id":"grunt","count":1,"spawn_interval":1,"hp_multiplier":1,"speed_multiplier":1},
{"enemy_id":"grunt","count":1,"spawn_interval":1,"hp_multiplier":1,"speed_multiplier":1}]}]}`
	valid, _ = parse_waves(overflow, "test", &level)
	testing.expect(t, !valid)
}

strings_replace :: proc(value, old, replacement: string) -> string {
	result, _ := strings.replace_all(value, old, replacement, context.temp_allocator)
	return result
}
