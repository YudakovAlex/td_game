package main

import "core:testing"

@(test)
test_wave_status_label_waiting_and_countdown :: proc(t: ^testing.T) {
	g := new(Game)
	defer free(g)
	g^ = Game{mode = .Playing, wave_state = .Waiting}

	testing.expect(t, wave_status_label(g) == "Start Wave [Space]")

	g.next_wave_timer = 1.2
	testing.expect(t, wave_status_label(g) == "Starting in 2s")

	g.next_wave_timer = 5
	testing.expect(t, wave_status_label(g) == "Starting in 5s")
}

@(test)
test_wave_status_label_active_states_include_progress :: proc(t: ^testing.T) {
	g := new(Game)
	defer free(g)
	g^ = Game{mode = .Playing, wave_count = 1, current_wave = 0}
	g.waves[0].group_count = 1
	g.waves[0].groups[0].count = 10
	g.wave_group_index = 0
	g.wave_spawned_count = 4
	g.enemy_count = 3

	g.wave_state = .Spawning
	testing.expect(t, wave_status_label(g) == "Spawning · 9 enemies left")

	g.wave_state = .Clearing
	g.wave_spawned_count = 10
	g.enemy_count = 2
	testing.expect(t, wave_status_label(g) == "Wave Clearing · 2 left")
}

@(test)
test_wave_status_label_finished_and_paused :: proc(t: ^testing.T) {
	g := new(Game)
	defer free(g)
	g^ = Game{mode = .Playing, wave_state = .Finished}
	testing.expect(t, wave_status_label(g) == "All Waves Cleared")

	g.mode = .Paused
	testing.expect(t, wave_status_label(g) == "Game Paused")
}
