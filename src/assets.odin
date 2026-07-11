package main

import "core:fmt"
import rl "vendor:raylib"

// Embed the runtime atlas in the executable so release builds do not depend on
// an assets directory or on the process working directory.
SPRITE_ATLAS_PNG :: #load("../assets/sprite_atlas.png")

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
	case .Count: return ""
	}
	return ""
}

load_assets :: proc(a: ^Assets) {
	image := rl.LoadImageFromMemory(
		fmt.ctprintf(".png"),
		raw_data(SPRITE_ATLAS_PNG),
		i32(len(SPRITE_ATLAS_PNG)),
	)
	if !rl.IsImageValid(image) { return }
	defer rl.UnloadImage(image)

	a.atlas = rl.LoadTextureFromImage(image)
	if rl.IsTextureValid(a.atlas) { rl.SetTextureFilter(a.atlas, .BILINEAR) }
}

unload_assets :: proc(a: ^Assets) {
	if rl.IsTextureValid(a.atlas) { rl.UnloadTexture(a.atlas) }
}

draw_asset :: proc(a: ^Assets, id: Asset_Id, center: Vec2, size: Vec2, rotation: f32, tint: rl.Color) -> bool {
	texture := a.atlas
	if !rl.IsTextureValid(texture) { return false }
	cell_w := f32(texture.width)/6
	cell_h := f32(texture.height)/4
	index := int(id)
	source := rl.Rectangle{f32(index%6)*cell_w, f32(index/6)*cell_h, cell_w, cell_h}
	dest := rl.Rectangle{center.x, center.y, size.x, size.y}
	rl.DrawTexturePro(texture, source, dest, vec2(size.x/2, size.y/2), rotation, tint)
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
