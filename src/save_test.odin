package main

import "core:testing"

@(test)
test_score_calculation :: proc(t: ^testing.T) {
	g := new(Game)
	defer free(g)
	g^ = Game{}
	g.wave_count = 10
	g.current_wave = 3
	g.score_gold_earned = 47
	g.lives = 12
	testing.expect(t, calculate_score(g) == 947)
}

@(test)
test_best_result_updates_score_and_lives_independently :: proc(t: ^testing.T) {
	data := Save_Data{}
	testing.expect(t, update_best_result(&data, 0, 500, 10))
	testing.expect(t, !update_best_result(&data, 0, 400, 9))
	testing.expect(t, update_best_result(&data, 0, 400, 12))
	testing.expect(t, data.levels[0].completed)
	testing.expect(t, data.levels[0].best_score == 500)
	testing.expect(t, data.levels[0].best_lives == 12)
}

@(test)
test_save_serialization_round_trip :: proc(t: ^testing.T) {
	data := Save_Data{}
	data.levels[0] = Saved_Level_Result{true, 1234, 17}
	data.levels[2] = Saved_Level_Result{true, 2345, 12}

	encoded := serialize_results(&data, 3)
	decoded, ok := parse_results(encoded, 3)
	testing.expect(t, ok)
	testing.expect(t, decoded.levels[0] == data.levels[0])
	testing.expect(t, decoded.levels[2] == data.levels[2])
	testing.expect(t, !decoded.levels[1].completed)
}

@(test)
test_malformed_save_is_rejected :: proc(t: ^testing.T) {
	_, ok := parse_results("not a Rune Siege save\n", MAX_LEVELS)
	testing.expect(t, !ok)

	_, ok = parse_results("RUNE_SIEGE_RESULTS 1\n0 bad 10 true\n", MAX_LEVELS)
	testing.expect(t, !ok)
}

@(test)
test_old_save_without_new_levels_remains_compatible :: proc(t: ^testing.T) {
	legacy := "RUNE_SIEGE_RESULTS 1\n0 800 18 true\n2 1200 16 true\n"
	decoded, ok := parse_results(legacy, MAX_LEVELS)
	testing.expect(t, ok)
	testing.expect(t, decoded.levels[0].best_score == 800)
	testing.expect(t, decoded.levels[2].best_lives == 16)
	testing.expect(t, !decoded.levels[3].completed)
}

@(test)
test_new_level_result_serializes_with_existing_save_format :: proc(t: ^testing.T) {
	data := Save_Data{}
	data.levels[5] = Saved_Level_Result{true, 3456, 14}
	encoded := serialize_results(&data, MAX_LEVELS)
	decoded, ok := parse_results(encoded, MAX_LEVELS)
	testing.expect(t, ok)
	testing.expect(t, decoded.levels[5] == data.levels[5])
}

@(test)
test_grasslands_has_selected_mixed_waves :: proc(t: ^testing.T) {
	g := new(Game)
	defer free(g)
	g^ = Game{}
	init_levels(g)
	defer unload_level_content(&g.levels)
	defer unload_content(&g.content)
	testing.expect(t, load_content(g))
	testing.expect(t, g.levels[0].waves[3].group_count == 2)
	testing.expect(t, g.levels[0].waves[5].group_count == 2)
	testing.expect(t, g.levels[0].waves[7].group_count == 3)
	testing.expect(t, g.levels[9].waves[3].group_count == 1)
}

@(test)
test_wave_groups_clear_sequentially :: proc(t: ^testing.T) {
	g := new(Game)
	defer free(g)
	g^ = Game{}
	init_levels(g)
	defer unload_level_content(&g.levels)
	defer unload_content(&g.content)
	testing.expect(t, load_content(g))
	g.current_level = 0
	g.levels[0].wave_count = 9
	g.waves = g.levels[0].waves
	g.wave_count = 9
	g.current_wave = 5
	g.wave_group_index = 0
	g.wave_state = .Clearing
	g.enemy_count = 0

	update_wave(g, 0, 0)
	testing.expect(t, g.wave_state == .Spawning)
	testing.expect(t, g.wave_group_index == 1)
	testing.expect(t, g.current_wave == 5)

	g.wave_spawned_count = g.waves[5].groups[1].count
	g.wave_state = .Clearing
	update_wave(g, 0, 0)
	testing.expect(t, g.wave_state == .Waiting)
	testing.expect(t, g.current_wave == 6)
}
