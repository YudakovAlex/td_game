package main

import "core:testing"

@(test)
test_wave_enemy_total_sums_groups :: proc(t: ^testing.T) {
	wave := Wave_Def{}
	wave.groups[0].count = 10
	wave.groups[1].count = 7
	wave.group_count = 2
	testing.expect(t, wave_enemy_total(wave) == 17)
}

@(test)
test_wave_summary_tracks_sequential_group_progress :: proc(t: ^testing.T) {
	g := Game{}
	g.wave_count = 1
	g.waves[0].groups[0].count = 10
	g.waves[0].groups[1].count = 7
	g.waves[0].group_count = 2
	g.current_wave = 0
	g.wave_group_index = 0
	g.wave_spawned_count = 4
	g.enemy_count = 3
	g.wave_state = .Spawning

	testing.expect(t, wave_enemy_total(g.waves[0]) == 17)
	testing.expect(t, wave_enemies_spawned(&g) == 4)
	testing.expect(t, wave_enemies_remaining(&g) == 16)

	g.wave_state = .Clearing
	g.wave_group_index = 1
	g.wave_spawned_count = 7
	g.enemy_count = 2
	testing.expect(t, wave_enemies_spawned(&g) == 17)
	testing.expect(t, wave_enemies_remaining(&g) == 2)
}

@(test)
test_wave_summary_is_empty_outside_active_wave :: proc(t: ^testing.T) {
	g := Game{}
	g.wave_count = 1
	g.waves[0].group_count = 1
	g.waves[0].groups[0].count = 10
	g.current_wave = 0
	g.wave_state = .Waiting
	g.enemy_count = 4

	testing.expect(t, wave_enemies_spawned(&g) == 0)
	testing.expect(t, wave_enemies_remaining(&g) == 0)
}

@(test)
test_wave_start_waits_for_automatic_countdown :: proc(t: ^testing.T) {
	g := Game{}
	g.wave_count = 1
	g.current_wave = 0
	g.wave_state = .Waiting
	g.next_wave_timer = NEXT_WAVE_DELAY

	try_start_wave(&g)
	testing.expect(t, g.wave_state == .Waiting)
	testing.expect(t, g.next_wave_timer == NEXT_WAVE_DELAY)

	g.next_wave_timer = 0
	try_start_wave(&g)
	testing.expect(t, g.wave_state == .Spawning)
}

@(test)
test_win_current_wave_advances_and_clears_wave :: proc(t: ^testing.T) {
	g := Game{}
	g.wave_count = 2
	g.current_wave = 0
	g.wave_state = .Spawning
	g.enemy_count = 1
	g.enemies[0].alive = true

	win_current_wave(&g)

	testing.expect(t, g.current_wave == 1)
	testing.expect(t, g.wave_state == .Waiting)
	testing.expect(t, g.enemy_count == 0)
	testing.expect(t, g.gold == 20)
	testing.expect(t, g.next_wave_timer == NEXT_WAVE_DELAY)
}

@(test)
test_win_current_wave_finishes_final_wave :: proc(t: ^testing.T) {
	g := Game{}
	g.wave_count = 1
	g.current_wave = 0
	g.wave_state = .Clearing

	win_current_wave(&g)

	testing.expect(t, g.current_wave == 1)
	testing.expect(t, g.wave_state == .Finished)
	testing.expect(t, g.next_wave_timer == 0)
}

@(test)
test_win_current_level_finishes_all_waves :: proc(t: ^testing.T) {
	g := Game{}
	g.wave_count = 3
	g.current_wave = 1
	g.wave_state = .Spawning
	g.enemy_count = 1

	win_current_level(&g)

	testing.expect(t, g.current_wave == 3)
	testing.expect(t, g.wave_state == .Finished)
	testing.expect(t, g.enemy_count == 0)
	testing.expect(t, g.next_wave_timer == 0)
}

@(test)
test_campaign_continues_into_ruined_city_and_stops_after_final_level :: proc(t: ^testing.T) {
	g := Game{}
	init_levels(&g)
	defer unload_level_content(&g.levels)
	defer unload_content(&g.content)
	testing.expect(t, load_content(&g))

	g.current_level = 8
	g.mode = .Victory
	continue_campaign(&g)
	testing.expect(t, g.current_level == 9)
	testing.expect(t, g.mode == .Playing)
	testing.expect(t, g.levels[g.current_level].name == "Forest Pass 1 - Trailhead")

	g.current_level = 98
	g.mode = .Victory
	continue_campaign(&g)
	testing.expect(t, g.current_level == 98)
	testing.expect(t, g.level_count == 99)
}
