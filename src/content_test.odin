package main

import "core:testing"
import "core:strings"

@(test)
test_content_files_load_current_definitions :: proc(t: ^testing.T) {
	g := Game{}
	init_levels(&g)
	defer unload_content(&g.content)
	testing.expect(t, load_content(&g))
	testing.expect(t, g.content.towers[int(Tower_Type.Arrow)].cost == 50)
	testing.expect(t, g.content.towers[int(Tower_Type.Flame)].burn_damage == 5)
	testing.expect(t, g.content.enemies[int(Enemy_Type.Armored)].physical_multiplier == 0.65)
	testing.expect(t, g.content.enemies[int(Enemy_Type.Armored)].magic_multiplier == 1.35)
	testing.expect(t, g.levels[0].wave_count == 15)
	testing.expect(t, g.levels[0].waves[5].group_count == 2)
	testing.expect(t, g.levels[0].waves[5].groups[0].enemy_type == .Runner)
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
