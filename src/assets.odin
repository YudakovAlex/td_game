package main

import "core:c"
import "core:fmt"
import "core:math"
import rl "vendor:raylib"

ATLAS_COLUMNS :: 6
ATLAS_ROWS    :: 5

// Embed the runtime atlas in the executable so release builds do not depend on
// an assets directory or on the process working directory.
SPRITE_ATLAS_PNG :: #load("../assets/sprite_atlas.png")

GRASSLANDS_BASE_PNG          :: #load("../assets/terrain/grasslands/base.png")
GRASSLANDS_ROAD_STRAIGHT_PNG :: #load("../assets/terrain/grasslands/road_straight.png")
GRASSLANDS_ROAD_CORNER_PNG   :: #load("../assets/terrain/grasslands/road_corner.png")
GRASSLANDS_SPAWN_PNG         :: #load("../assets/terrain/grasslands/spawn.png")
GRASSLANDS_EXIT_PNG          :: #load("../assets/terrain/grasslands/exit.png")
GRASSLANDS_FARM_PNG          :: #load("../assets/terrain/grasslands/landmark_01.png")
GRASSLANDS_FENCE_PNG         :: #load("../assets/terrain/grasslands/landmark_02.png")
GRASSLANDS_STONES_PNG        :: #load("../assets/terrain/grasslands/landmark_03.png")
GRASSLANDS_HAY_CART_PNG      :: #load("../assets/terrain/grasslands/landmark_04.png")
GRASSLANDS_WELL_PNG          :: #load("../assets/terrain/grasslands/landmark_05.png")
GRASSLANDS_SMALL_BRIDGE_PNG  :: #load("../assets/terrain/grasslands/landmark_06.png")
GRASSLANDS_WATCHTOWER_PNG    :: #load("../assets/terrain/grasslands/landmark_07.png")
GRASSLANDS_HEARTH_PNG        :: #load("../assets/terrain/grasslands/hearth.png")
GRASSLANDS_ACCENT_PNG        :: #load("../assets/terrain/grasslands/accent.png")
GRASSLANDS_CROSSING_PNG      :: #load("../assets/terrain/grasslands/crossing.png")
GRASSLANDS_ROAD_EDGE_PNG     :: #load("../assets/terrain/grasslands/road_edge.png")

asset_path :: proc(id: Asset_Id) -> string {
	switch id {
	case .Grass: return "assets/terrain/grass.png"
	case .Path: return "assets/terrain/path.png"
	case .Spawn: return "assets/terrain/spawn.png"
	case .Exit: return "assets/terrain/exit.png"
	case .Tower_Arrow: return "assets/towers/arrow.png"
	case .Tower_Cannon: return "assets/towers/cannon.png"
	case .Tower_Frost: return "assets/towers/frost.png"
	case .Tower_Flame: return "assets/towers/flame.png"
	case .Enemy_Grunt: return "assets/enemies/grunt.png"
	case .Enemy_Runner: return "assets/enemies/runner.png"
	case .Enemy_Brute: return "assets/enemies/brute.png"
	case .Enemy_Boss: return "assets/enemies/boss.png"
	case .Enemy_Armored: return "assets/enemies/armored.png"
	case .Enemy_Wraith: return "assets/enemies/wraith.png"
	case .Enemy_Siege_Beast: return "assets/enemies/siege_beast.png"
	case .Projectile_Arrow: return "assets/projectiles/arrow.png"
	case .Projectile_Cannon: return "assets/projectiles/cannon.png"
	case .Projectile_Frost: return "assets/projectiles/frost.png"
	case .Projectile_Flame: return "assets/projectiles/flame.png"
	case .Icon_Gold: return "assets/ui/gold.png"
	case .Icon_Lives: return "assets/ui/lives.png"
	case .Icon_Wave: return "assets/ui/wave.png"
	case .Icon_Upgrade: return "assets/ui/upgrade.png"
	case .Icon_Sell: return "assets/ui/sell.png"
	case .Icon_Speed: return "assets/ui/speed.png"
	case .Path_Turn: return "assets/terrain/path_turn.png"
	case .Count: return ""
	}
	return ""
}

load_assets :: proc(a: ^Assets) {
	load_sounds(&a.sounds)

	image := rl.LoadImageFromMemory(
		fmt.ctprintf(".png"),
		raw_data(SPRITE_ATLAS_PNG),
		i32(len(SPRITE_ATLAS_PNG)),
	)
	if !rl.IsImageValid(image) { return }
	defer rl.UnloadImage(image)

	a.atlas = rl.LoadTextureFromImage(image)
	if rl.IsTextureValid(a.atlas) { rl.SetTextureFilter(a.atlas, .BILINEAR) }

	a.grasslands[int(Grasslands_Asset_Id.Base)] = load_embedded_texture(GRASSLANDS_BASE_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Road_Straight)] = load_embedded_texture(GRASSLANDS_ROAD_STRAIGHT_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Road_Corner)] = load_embedded_texture(GRASSLANDS_ROAD_CORNER_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Spawn)] = load_embedded_texture(GRASSLANDS_SPAWN_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Exit)] = load_embedded_texture(GRASSLANDS_EXIT_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Farm)] = load_embedded_texture(GRASSLANDS_FARM_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Fence)] = load_embedded_texture(GRASSLANDS_FENCE_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Standing_Stones)] = load_embedded_texture(GRASSLANDS_STONES_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Hay_Cart)] = load_embedded_texture(GRASSLANDS_HAY_CART_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Well)] = load_embedded_texture(GRASSLANDS_WELL_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Small_Bridge)] = load_embedded_texture(GRASSLANDS_SMALL_BRIDGE_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Watchtower)] = load_embedded_texture(GRASSLANDS_WATCHTOWER_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Hearth)] = load_embedded_texture(GRASSLANDS_HEARTH_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Accent)] = load_embedded_texture(GRASSLANDS_ACCENT_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Crossing)] = load_embedded_texture(GRASSLANDS_CROSSING_PNG)
	a.grasslands[int(Grasslands_Asset_Id.Road_Edge)] = load_embedded_texture(GRASSLANDS_ROAD_EDGE_PNG)
}

load_embedded_texture :: proc(data: []u8) -> rl.Texture2D {
	image := rl.LoadImageFromMemory(
		fmt.ctprintf(".png"),
		raw_data(data),
		i32(len(data)),
	)
	if !rl.IsImageValid(image) { return rl.Texture2D{} }
	defer rl.UnloadImage(image)

	texture := rl.LoadTextureFromImage(image)
	if rl.IsTextureValid(texture) { rl.SetTextureFilter(texture, .BILINEAR) }
	return texture
}

SOUND_SAMPLE_RATE :: 44100

make_tone_sound :: proc(start_frequency, end_frequency, duration, volume: f32) -> rl.Sound {
	if !rl.IsAudioDeviceReady() || duration <= 0 {
		return rl.Sound{}
	}

	frame_count := int(f32(SOUND_SAMPLE_RATE) * duration)
	samples := make([]i16, frame_count)
	defer delete(samples)

	for i := 0; i < frame_count; i += 1 {
		progress := f32(i) / f32(frame_count)
		frequency := start_frequency + (end_frequency-start_frequency)*progress
		phase := 2 * math.PI * f64(frequency) * f64(i) / f64(SOUND_SAMPLE_RATE)
		envelope := min(progress/0.08, (1-progress)/0.18)
		envelope = min(max(envelope, 0), 1)
		amplitude := math.sin(phase) * f64(envelope) * f64(volume)
		samples[i] = i16(amplitude * 32767)
	}

	wave := rl.Wave{
		frameCount = c.uint(frame_count),
		sampleRate = c.uint(SOUND_SAMPLE_RATE),
		sampleSize = 16,
		channels   = 1,
		data       = raw_data(samples),
	}
	return rl.LoadSoundFromWave(wave)
}

load_sounds :: proc(s: ^Sounds) {
	if !rl.IsAudioDeviceReady() { return }

	s.action = make_tone_sound(520, 760, 0.08, 0.22)
	s.impact = make_tone_sound(180, 90, 0.045, 0.14)
	s.wave_start = make_tone_sound(360, 720, 0.18, 0.20)
	s.boss = make_tone_sound(140, 70, 0.35, 0.24)
	s.leak = make_tone_sound(110, 55, 0.22, 0.22)
	s.victory = make_tone_sound(520, 780, 0.30, 0.22)
	s.defeat = make_tone_sound(200, 80, 0.30, 0.22)
}

unload_sounds :: proc(s: ^Sounds) {
	if rl.IsSoundValid(s.action) { rl.UnloadSound(s.action) }
	if rl.IsSoundValid(s.impact) { rl.UnloadSound(s.impact) }
	if rl.IsSoundValid(s.wave_start) { rl.UnloadSound(s.wave_start) }
	if rl.IsSoundValid(s.boss) { rl.UnloadSound(s.boss) }
	if rl.IsSoundValid(s.leak) { rl.UnloadSound(s.leak) }
	if rl.IsSoundValid(s.victory) { rl.UnloadSound(s.victory) }
	if rl.IsSoundValid(s.defeat) { rl.UnloadSound(s.defeat) }
}

unload_assets :: proc(a: ^Assets) {
	unload_sounds(&a.sounds)
	if rl.IsTextureValid(a.atlas) { rl.UnloadTexture(a.atlas) }
	for i := 0; i < int(Grasslands_Asset_Id.Count); i += 1 {
		if rl.IsTextureValid(a.grasslands[i]) { rl.UnloadTexture(a.grasslands[i]) }
	}
}

draw_asset :: proc(a: ^Assets, id: Asset_Id, center: Vec2, size: Vec2, rotation: f32, tint: rl.Color) -> bool {
	if id >= .Count { return false }
	texture := a.atlas
	if !rl.IsTextureValid(texture) { return false }
	cell_w := f32(texture.width)/ATLAS_COLUMNS
	cell_h := f32(texture.height)/ATLAS_ROWS
	index := int(id)
	source := rl.Rectangle{f32(index%ATLAS_COLUMNS)*cell_w, f32(index/ATLAS_COLUMNS)*cell_h, cell_w, cell_h}
	draw_texture(texture, source, center, size, rotation, tint)
	return true
}

draw_texture :: proc(texture: rl.Texture2D, source: rl.Rectangle, center: Vec2, size: Vec2, rotation: f32, tint: rl.Color) {
	dest := rl.Rectangle{center.x, center.y, size.x, size.y}
	rl.DrawTexturePro(texture, source, dest, vec2(size.x/2, size.y/2), rotation, tint)
}

draw_grasslands_asset :: proc(a: ^Assets, id: Grasslands_Asset_Id, center: Vec2, size: Vec2, rotation: f32, tint: rl.Color) -> bool {
	if id >= .Count { return false }
	texture := a.grasslands[int(id)]
	if !rl.IsTextureValid(texture) { return false }
	source := rl.Rectangle{0, 0, f32(texture.width), f32(texture.height)}
	draw_texture(texture, source, center, size, rotation, tint)
	return true
}

projectile_asset :: proc(kind: Tower_Type) -> Asset_Id {
	switch kind {
	case .Arrow: return .Projectile_Arrow
	case .Cannon: return .Projectile_Cannon
	case .Frost: return .Projectile_Frost
	case .Flame: return .Projectile_Flame
	case .None: return .Projectile_Arrow
	}
	return .Projectile_Arrow
}
