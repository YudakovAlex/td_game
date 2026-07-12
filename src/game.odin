package main

import "core:math"
import rl "vendor:raylib"

SCREEN_WIDTH  :: 1280
SCREEN_HEIGHT :: 720

TILE_SIZE :: 40
MAP_W     :: 24
MAP_H     :: 18

UI_X :: MAP_W * TILE_SIZE
UI_W :: SCREEN_WIDTH - UI_X

MAX_ENEMIES     :: 512
MAX_TOWERS      :: 128
MAX_PROJECTILES :: 512
MAX_WAVES       :: 20
MAX_WAVE_GROUPS :: 3
MAX_EFFECTS     :: 256
MAX_LEVELS      :: 6
MAX_ROUTES      :: 2
MAX_PATH_POINTS :: 12

NEXT_WAVE_DELAY :: f32(5)

Game_Mode :: enum {
	Playing,
	Paused,
	Victory,
	Defeat,
}

Wave_State :: enum {
	Waiting,
	Spawning,
	Clearing,
	Finished,
}

Tile_Type :: enum {
	Blocked,
	Buildable,
	Path,
	Spawn,
	Exit,
}

Tower_Type :: enum {
	None,
	Arrow,
	Cannon,
	Frost,
	Flame,
}

Target_Mode :: enum {
	First,
	Weakest,
	Strongest,
}

Enemy_Type :: enum {
	Grunt,
	Runner,
	Brute,
	Boss,
	Armored,
	Wraith,
	Siege_Beast,
}

Damage_Type :: enum {
	Physical,
	Magic,
	Elemental,
}

Asset_Id :: enum {
	Grass, Path, Spawn, Exit,
	Tower_Arrow, Tower_Cannon, Tower_Frost, Tower_Flame,
	Enemy_Grunt, Enemy_Runner, Enemy_Brute, Enemy_Boss, Enemy_Armored,
	Projectile_Arrow, Projectile_Cannon, Projectile_Frost, Projectile_Flame,
	Icon_Gold, Icon_Lives, Icon_Wave, Icon_Upgrade, Icon_Sell, Icon_Speed,
	Count,
}

Effect_Type :: enum { Spark, Explosion, Frost_Burst, Flame_Burst, Burn_Ember, Portal }

Sound_Id :: enum {
	Action,
	Impact,
	Wave_Start,
	Boss,
	Leak,
	Victory,
	Defeat,
}

Vec2 :: rl.Vector2

Viewport :: struct {
	offset_x: f32,
	offset_y: f32,
	width:    f32,
	height:   f32,
	scale:    f32,
}

Tile :: struct {
	kind: Tile_Type,
}

Tower_Def :: struct {
	name:           string,
	cost:           int,
	damage:         f32,
	range:          f32,
	cooldown:       f32,
	projectile_spd: f32,
	splash_radius:  f32,
	damage_type:    Damage_Type,
	slow_amount:    f32,
	slow_duration:  f32,
	burn_damage:    f32,
	burn_duration:  f32,
	asset:          Asset_Id,
	role:           string,
	color:          rl.Color,
}

Enemy_Def :: struct {
	name:                 string,
	max_hp:               f32,
	speed:                f32,
	gold_reward:          int,
	lives_damage:         int,
	asset:                Asset_Id,
	resistance:           string,
	physical_multiplier:  f32,
	magic_multiplier:     f32,
	elemental_multiplier: f32,
	color:                rl.Color,
}

Content_Data :: struct {
	towers:  [5]Tower_Def,
	enemies: [7]Enemy_Def,
}

Wave_Def :: struct {
	groups:     [MAX_WAVE_GROUPS]Wave_Group,
	group_count: int,
}

Wave_Group :: struct {
	enemy_type:     Enemy_Type,
	count:          int,
	spawn_interval: f32,
	hp_mult:        f32,
	speed_mult:     f32,
}

Path_Route :: struct {
	points: [MAX_PATH_POINTS]Vec2,
	point_count: int,
}

Level_Def :: struct {
	name: string,
	starting_gold: int,
	starting_lives: int,
	routes: [MAX_ROUTES]Path_Route,
	route_count: int,
	waves: [MAX_WAVES]Wave_Def,
	wave_count: int,
}

Enemy :: struct {
	kind: Enemy_Type,

	pos:    Vec2,
	hp:     f32,
	max_hp: f32,

	speed:      f32,
	path_index: int,
	route_index: int,

	alive: bool,

	gold_reward:  int,
	lives_damage: int,

	slow_timer:  f32,
	slow_amount: f32,

	burn_timer:    f32,
	burn_tick:     f32,
	burn_damage:   f32,
	damage_flash:  f32,
}

Tower :: struct {
	kind: Tower_Type,

	tile_x: int,
	tile_y: int,
	pos:    Vec2,

	level: int,
	target_mode: Target_Mode,

	cooldown_timer: f32,
	total_invested: int,
	aim_angle:      f32,
	recoil:         f32,
}

Projectile :: struct {
	active: bool,

	pos: Vec2,
	vel: Vec2,

	target_index: int,

	damage:        f32,
	damage_type:   Damage_Type,
	splash_radius: f32,

	slow_amount:   f32,
	slow_duration: f32,
	burn_damage:   f32,
	burn_duration: f32,
	asset:         Asset_Id,

	color: rl.Color,
}

Visual_Effect :: struct {
	active:   bool,
	kind:     Effect_Type,
	pos:      Vec2,
	radius:   f32,
	age:      f32,
	lifetime: f32,
	color:    rl.Color,
}

Sounds :: struct {
	action:       rl.Sound,
	impact:       rl.Sound,
	wave_start:   rl.Sound,
	boss:         rl.Sound,
	leak:         rl.Sound,
	victory:      rl.Sound,
	defeat:       rl.Sound,
	impact_timer: f32,
}

Assets :: struct {
	atlas:  rl.Texture2D,
	sounds: Sounds,
}

Game :: struct {
	mode: Game_Mode,
	restart_confirmation: bool,
	quit_requested: bool,
	levels: [MAX_LEVELS]Level_Def,
	level_count: int,
	current_level: int,

	tiles: [MAP_H][MAP_W]Tile,

	gold:  int,
	lives: int,
	enemies_defeated: int,
	enemies_leaked:   int,
	score_gold_earned: int,
	result_score:      int,
	result_saved:      bool,
	save:              Save_Data,
	content:           Content_Data,

	selected_tower_type:  Tower_Type,
	selected_tower_index: int,

	enemies:    [MAX_ENEMIES]Enemy,
	enemy_count: int,

	towers:    [MAX_TOWERS]Tower,
	tower_count: int,

	projectiles: [MAX_PROJECTILES]Projectile,
	effects:     [MAX_EFFECTS]Visual_Effect,
	assets:      Assets,

	waves:      [MAX_WAVES]Wave_Def,
	wave_count: int,
	current_wave: int,

	wave_state:         Wave_State,
	wave_group_index:   int,
	wave_spawned_count: int,
	wave_spawn_timer:   f32,
	wave_route_cursor:  int,
	next_wave_timer:    f32,

	game_speed: f32,
	visual_time: f32,
}

get_tower_def :: proc(g: ^Game, kind: Tower_Type) -> Tower_Def {
	if kind < .Arrow || kind > .Flame { return Tower_Def{} }
	return g.content.towers[int(kind)]
}

get_enemy_def :: proc(g: ^Game, kind: Enemy_Type) -> Enemy_Def {
	if kind < .Grunt || kind > .Siege_Beast { return Enemy_Def{} }
	return g.content.enemies[int(kind)]
}

vec2 :: proc(x, y: f32) -> Vec2 {
	return Vec2{x, y}
}

get_viewport :: proc() -> Viewport {
	screen_w := f32(rl.GetScreenWidth())
	screen_h := f32(rl.GetScreenHeight())

	scale_x := screen_w / f32(SCREEN_WIDTH)
	scale_y := screen_h / f32(SCREEN_HEIGHT)

	scale := scale_x
	if scale_y < scale {
		scale = scale_y
	}
	if scale <= 0 {
		scale = 1
	}

	width := f32(SCREEN_WIDTH) * scale
	height := f32(SCREEN_HEIGHT) * scale

	return Viewport{
		offset_x = (screen_w - width) * 0.5,
		offset_y = (screen_h - height) * 0.5,
		width    = width,
		height   = height,
		scale    = scale,
	}
}

screen_to_game_pos :: proc(pos: Vec2) -> Vec2 {
	vp := get_viewport()
	return vec2(
		(pos.x-vp.offset_x)/vp.scale,
		(pos.y-vp.offset_y)/vp.scale,
	)
}

point_in_game_view :: proc(pos: Vec2) -> bool {
	vp := get_viewport()
	return pos.x >= vp.offset_x &&
		pos.y >= vp.offset_y &&
		pos.x < vp.offset_x+vp.width &&
		pos.y < vp.offset_y+vp.height
}

v_add :: proc(a, b: Vec2) -> Vec2 {
	return Vec2{a.x + b.x, a.y + b.y}
}

v_sub :: proc(a, b: Vec2) -> Vec2 {
	return Vec2{a.x - b.x, a.y - b.y}
}

v_mul :: proc(a: Vec2, s: f32) -> Vec2 {
	return Vec2{a.x * s, a.y * s}
}

v_len_sq :: proc(a: Vec2) -> f32 {
	return a.x*a.x + a.y*a.y
}

v_len :: proc(a: Vec2) -> f32 {
	return f32(math.sqrt(f64(v_len_sq(a))))
}

v_norm :: proc(a: Vec2) -> Vec2 {
	l := v_len(a)
	if l <= 0.0001 {
		return Vec2{0, 0}
	}
	return Vec2{a.x / l, a.y / l}
}

dist_sq :: proc(a, b: Vec2) -> f32 {
	return v_len_sq(v_sub(a, b))
}

tile_center :: proc(x, y: int) -> Vec2 {
	return Vec2{
		f32(x*TILE_SIZE + TILE_SIZE/2),
		f32(y*TILE_SIZE + TILE_SIZE/2),
	}
}

screen_to_tile :: proc(pos: Vec2) -> (int, int) {
	return int(pos.x) / TILE_SIZE, int(pos.y) / TILE_SIZE
}

point_in_rect :: proc(p: Vec2, x, y, w, h: int) -> bool {
	return p.x >= f32(x) &&
		p.y >= f32(y) &&
		p.x < f32(x+w) &&
		p.y < f32(y+h)
}

init_game :: proc() -> (Game, bool) {
	g := Game{}
	init_levels(&g)
	if !load_content(&g) {
		unload_content(&g.content)
		unload_level_content(&g.levels)
		return g, false
	}
	g.save = load_results(g.level_count)
	g.current_level = 0
	load_level(&g, g.current_level)
	load_assets(&g.assets)

	return g, true
}

play_game_sound :: proc(g: ^Game, id: Sound_Id) {
	if !rl.IsAudioDeviceReady() { return }

	if id == .Impact {
		if g.assets.sounds.impact_timer > 0 { return }
		g.assets.sounds.impact_timer = 0.05
	}

	sound := rl.Sound{}
	switch id {
	case .Action:     sound = g.assets.sounds.action
	case .Impact:     sound = g.assets.sounds.impact
	case .Wave_Start: sound = g.assets.sounds.wave_start
	case .Boss:       sound = g.assets.sounds.boss
	case .Leak:       sound = g.assets.sounds.leak
	case .Victory:    sound = g.assets.sounds.victory
	case .Defeat:     sound = g.assets.sounds.defeat
	}

	if rl.IsSoundValid(sound) { rl.PlaySound(sound) }
}

update_game :: proc(g: ^Game, raw_dt: f32) {
	if g.assets.sounds.impact_timer > 0 {
		g.assets.sounds.impact_timer -= raw_dt
	}

	if g.mode == .Paused {
		handle_pause_input(g)
		return
	}
	if g.mode != .Playing {
		handle_result_input(g)
		return
	}

	handle_input(g)
	if g.mode != .Playing { return }
	g.visual_time += raw_dt

	dt := raw_dt * g.game_speed

	update_wave(g, dt, raw_dt)
	update_enemies(g, dt)
	update_towers(g, dt)
	update_projectiles(g, dt)
	update_effects(g, raw_dt)

	cleanup_dead_enemies(g)

	if g.lives <= 0 {
		g.result_score = calculate_score(g)
		g.mode = .Defeat
		play_game_sound(g, .Defeat)
	} else if g.current_wave >= g.wave_count && g.wave_state == .Finished && g.enemy_count == 0 {
		g.mode = .Victory
		play_game_sound(g, .Victory)
		save_completed_result(g)
	}
}

waves_cleared :: proc(g: ^Game) -> int {
	return clamp(g.current_wave, 0, g.wave_count)
}

waves_remaining :: proc(g: ^Game) -> int {
	return max(g.wave_count-waves_cleared(g), 0)
}

displayed_wave :: proc(g: ^Game) -> int {
	if g.wave_count <= 0 { return 0 }
	if g.wave_state == .Finished { return g.wave_count }
	return clamp(g.current_wave+1, 1, g.wave_count)
}

calculate_score :: proc(g: ^Game) -> int {
	return g.score_gold_earned + waves_cleared(g)*100 + max(g.lives, 0)*50
}

displayed_score :: proc(g: ^Game) -> int {
	if g.mode == .Victory || g.mode == .Defeat { return g.result_score }
	return calculate_score(g)
}

save_completed_result :: proc(g: ^Game) {
	if g.result_saved { return }
	g.result_score = calculate_score(g)
	if update_best_result(&g.save, g.current_level, g.result_score, max(g.lives, 0)) {
		save_results(&g.save, g.level_count)
	}
	g.result_saved = true
}

change_game_speed :: proc(g: ^Game, delta: f32) {
	g.game_speed += delta
	if g.game_speed < 1 { g.game_speed = 1 }
	if g.game_speed > 3 { g.game_speed = 3 }
}

continue_campaign :: proc(g: ^Game) {
	if g.mode != .Victory { return }
	if g.current_level+1 >= g.level_count { return }
	g.current_level += 1
	load_level(g, g.current_level)
}

handle_result_input :: proc(g: ^Game) {
	mouse_screen := rl.GetMousePosition()
	mouse := screen_to_game_pos(mouse_screen)
	activate := rl.IsKeyPressed(.ENTER)
	if rl.IsMouseButtonPressed(.LEFT) && point_in_game_view(mouse_screen) && point_in_rect(mouse, 520, 452, 240, 48) {
		activate = true
	}
	if !activate { return }
	if g.mode == .Defeat {
		load_level(g, g.current_level)
	} else if g.mode == .Victory && g.current_level+1 < g.level_count {
		continue_campaign(g)
	}
}

handle_pause_input :: proc(g: ^Game) {
	mouse_screen := rl.GetMousePosition()
	mouse := screen_to_game_pos(mouse_screen)
	click := rl.IsMouseButtonPressed(.LEFT) && point_in_game_view(mouse_screen)

	if g.restart_confirmation {
		if rl.IsKeyPressed(.ESCAPE) || (click && point_in_rect(mouse, 650, 410, 140, 46)) {
			g.restart_confirmation = false
			return
		}
		if rl.IsKeyPressed(.ENTER) || (click && point_in_rect(mouse, 490, 410, 140, 46)) {
			load_level(g, g.current_level)
		}
		return
	}

	if rl.IsKeyPressed(.ESCAPE) || (click && point_in_rect(mouse, 520, 320, 240, 46)) {
		g.mode = .Playing
		return
	}
	if rl.IsKeyPressed(.R) || (click && point_in_rect(mouse, 520, 380, 240, 46)) {
		g.restart_confirmation = true
		return
	}
	if rl.IsKeyPressed(.Q) || (click && point_in_rect(mouse, 520, 440, 240, 46)) {
		g.quit_requested = true
	}
}

handle_input :: proc(g: ^Game) {
	mouse_screen := rl.GetMousePosition()
	mouse := screen_to_game_pos(mouse_screen)
	if rl.IsKeyPressed(.ESCAPE) {
		g.mode = .Paused
		g.restart_confirmation = false
		return
	}

	if rl.IsKeyPressed(.ONE) {
		g.selected_tower_type = .Arrow
		g.selected_tower_index = -1
	}
	if rl.IsKeyPressed(.TWO) {
		g.selected_tower_type = .Cannon
		g.selected_tower_index = -1
	}
	if rl.IsKeyPressed(.THREE) {
		g.selected_tower_type = .Frost
		g.selected_tower_index = -1
	}
	if rl.IsKeyPressed(.FOUR) {
		g.selected_tower_type = .Flame
		g.selected_tower_index = -1
	}

	if rl.IsKeyPressed(.SPACE) {
		try_start_wave(g)
	}

	if rl.IsKeyPressed(.EQUAL) {
		change_game_speed(g, 1)
	}

	if rl.IsKeyPressed(.MINUS) {
		change_game_speed(g, -1)
	}

	if rl.IsKeyPressed(.TAB) && g.selected_tower_index >= 0 {
		cycle_tower_target_mode(g, g.selected_tower_index)
	}

	if rl.IsMouseButtonPressed(.LEFT) {
		if point_in_game_view(mouse_screen) {
			if mouse.x < f32(UI_X) {
				handle_map_click(g, mouse)
			} else {
				handle_ui_click(g, mouse)
			}
		}
	}

	if rl.IsMouseButtonPressed(.RIGHT) {
		g.selected_tower_type = .None
		g.selected_tower_index = -1
	}

	if rl.IsKeyPressed(.U) && g.selected_tower_index >= 0 {
		upgrade_tower(g, g.selected_tower_index)
	}

	if rl.IsKeyPressed(.S) && g.selected_tower_index >= 0 {
		sell_tower(g, g.selected_tower_index)
	}
}

handle_map_click :: proc(g: ^Game, mouse: Vec2) {
	tx, ty := screen_to_tile(mouse)

	if tx < 0 || tx >= MAP_W || ty < 0 || ty >= MAP_H {
		return
	}

	tower_index := tower_at_tile(g, tx, ty)
	if tower_index >= 0 {
		g.selected_tower_index = tower_index
		g.selected_tower_type = .None
		return
	}

	if g.selected_tower_type != .None {
		place_tower(g, g.selected_tower_type, tx, ty)
	}
}

handle_ui_click :: proc(g: ^Game, mouse: Vec2) {
	if point_in_rect(mouse, UI_X+174, 10, 66, 30) {
		g.mode = .Paused
		g.restart_confirmation = false
		return
	}
	if point_in_rect(mouse, UI_X+20, 126, 220, 42) {
		g.selected_tower_type = .Arrow
		g.selected_tower_index = -1
	}
	if point_in_rect(mouse, UI_X+20, 176, 220, 42) {
		g.selected_tower_type = .Cannon
		g.selected_tower_index = -1
	}
	if point_in_rect(mouse, UI_X+20, 226, 220, 42) {
		g.selected_tower_type = .Frost
		g.selected_tower_index = -1
	}
	if point_in_rect(mouse, UI_X+20, 276, 220, 42) {
		g.selected_tower_type = .Flame
		g.selected_tower_index = -1
	}
	if point_in_rect(mouse, UI_X+20, 326, 220, 42) {
		try_start_wave(g)
	}
	if point_in_rect(mouse, UI_X+154, 374, 38, 32) {
		change_game_speed(g, -1)
	}
	if point_in_rect(mouse, UI_X+202, 374, 38, 32) {
		change_game_speed(g, 1)
	}

	if g.selected_tower_index >= 0 && g.selected_tower_index < g.tower_count {
		if point_in_rect(mouse, UI_X+20, 598, 220, 24) {
			cycle_tower_target_mode(g, g.selected_tower_index)
		}
		if point_in_rect(mouse, UI_X+20, 474, 108, 34) {
			upgrade_tower(g, g.selected_tower_index)
		}
		if point_in_rect(mouse, UI_X+136, 474, 104, 34) {
			sell_tower(g, g.selected_tower_index)
		}
	}
}
