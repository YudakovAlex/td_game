package main

import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE, .WINDOW_HIGHDPI, .VSYNC_HINT})
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "2D Tower Defense - Odin Prototype")
	defer rl.CloseWindow()
	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()
	// Escape is a gameplay control; closing remains available through the window controls.
	rl.SetExitKey(.KEY_NULL)

	rl.SetWindowMinSize(960, 540)

	monitor := rl.GetCurrentMonitor()
	monitor_w := rl.GetMonitorWidth(monitor) * 9 / 10
	monitor_h := rl.GetMonitorHeight(monitor) * 9 / 10
	window_w := monitor_w
	window_h := window_w * SCREEN_HEIGHT / SCREEN_WIDTH
	if window_h > monitor_h {
		window_h = monitor_h
		window_w = window_h * SCREEN_WIDTH / SCREEN_HEIGHT
	}
	if window_w < SCREEN_WIDTH {
		window_w = SCREEN_WIDTH
		window_h = SCREEN_HEIGHT
	}
	rl.SetWindowSize(window_w, window_h)

	game_render_target = rl.LoadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT)
	defer rl.UnloadRenderTexture(game_render_target)

	rl.SetTargetFPS(60)

	game := new(Game)
	defer free(game)
	if !init_game(game) { return }
	defer unload_content(&game.content)
	defer unload_level_content(&game.levels)
	defer unload_assets(&game.assets)

	for !rl.WindowShouldClose() && !game.quit_requested {
		update_game(game, rl.GetFrameTime())
		draw_game(game)
	}
}
