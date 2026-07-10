package main

import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE, .WINDOW_HIGHDPI, .VSYNC_HINT})
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "2D Tower Defense - Odin Prototype")
	defer rl.CloseWindow()
	// Escape is a gameplay control; closing remains available through the window controls.
	rl.SetExitKey(.KEY_NULL)

	rl.SetWindowMinSize(960, 540)

	monitor := rl.GetCurrentMonitor()
	window_w := rl.GetMonitorWidth(monitor) * 9 / 10
	window_h := rl.GetMonitorHeight(monitor) * 9 / 10
	if window_w < SCREEN_WIDTH {
		window_w = SCREEN_WIDTH
	}
	if window_h < SCREEN_HEIGHT {
		window_h = SCREEN_HEIGHT
	}
	rl.SetWindowSize(window_w, window_h)

	game_render_target = rl.LoadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT)
	defer rl.UnloadRenderTexture(game_render_target)

	rl.SetTargetFPS(60)

	game := init_game()
	defer unload_assets(&game.assets)

	for !rl.WindowShouldClose() && !game.quit_requested {
		update_game(&game, rl.GetFrameTime())
		draw_game(&game)
	}
}
