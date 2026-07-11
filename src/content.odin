package main

import "core:fmt"
import "core:os"
import json "core:encoding/json"
import "core:strings"
import rl "vendor:raylib"

CONTENT_DIR     :: "data"
CONTENT_VERSION :: 1

Raw_Tower_Def :: struct {
	id:              string `json:"id"`,
	name:            string `json:"name"`,
	cost:            int    `json:"cost"`,
	damage:          f32    `json:"damage"`,
	range:           f32    `json:"range"`,
	cooldown:        f32    `json:"cooldown"`,
	projectile_spd:  f32    `json:"projectile_speed"`,
	splash_radius:   f32    `json:"splash_radius"`,
	damage_type:     string `json:"damage_type"`,
	slow_amount:     f32    `json:"slow_amount"`,
	slow_duration:   f32    `json:"slow_duration"`,
	burn_damage:     f32    `json:"burn_damage"`,
	burn_duration:   f32    `json:"burn_duration"`,
	asset:           string `json:"asset"`,
	role:            string `json:"role"`,
	color:           [4]u8  `json:"color"`,
}

Raw_Tower_File :: struct {
	version: int              `json:"version"`,
	towers:  []Raw_Tower_Def `json:"towers"`,
}

Raw_Enemy_Def :: struct {
	id:                   string `json:"id"`,
	name:                 string `json:"name"`,
	max_hp:               f32    `json:"max_hp"`,
	speed:                f32    `json:"speed"`,
	gold_reward:          int    `json:"gold_reward"`,
	lives_damage:         int    `json:"lives_damage"`,
	asset:                string `json:"asset"`,
	resistance:           string `json:"resistance"`,
	physical_multiplier:  f32    `json:"physical_multiplier"`,
	magic_multiplier:     f32    `json:"magic_multiplier"`,
	elemental_multiplier: f32    `json:"elemental_multiplier"`,
	color:                [4]u8  `json:"color"`,
}

Raw_Enemy_File :: struct {
	version: int              `json:"version"`,
	enemies: []Raw_Enemy_Def `json:"enemies"`,
}

Raw_Wave_Group :: struct {
	enemy_id:        string `json:"enemy_id"`,
	count:           int    `json:"count"`,
	spawn_interval:  f32    `json:"spawn_interval"`,
	hp_mult:         f32    `json:"hp_multiplier"`,
	speed_mult:      f32    `json:"speed_multiplier"`,
}

Raw_Wave_Def :: struct {
	groups: []Raw_Wave_Group `json:"groups"`,
}

Raw_Wave_File :: struct {
	version: int            `json:"version"`,
	level:   string         `json:"level"`,
	waves:   []Raw_Wave_Def `json:"waves"`,
}

Raw_Map_Point :: struct {
	x: f32 `json:"x"`,
	y: f32 `json:"y"`,
}

Raw_Map_Route :: struct {
	points: []Raw_Map_Point `json:"points"`,
}

Raw_Map_File :: struct {
	version:        int             `json:"version"`,
	level:          string          `json:"level"`,
	name:           string          `json:"name"`,
	starting_gold:  int             `json:"starting_gold"`,
	starting_lives: int             `json:"starting_lives"`,
	routes:         []Raw_Map_Route `json:"routes"`,
}

clone_content_string :: proc(value: string) -> string {
	cloned, err := strings.clone(value, context.allocator)
	if err != nil { return "" }
	return cloned
}

unload_content :: proc(content: ^Content_Data) {
	for i := 0; i < len(content.towers); i += 1 {
		delete(content.towers[i].name)
		delete(content.towers[i].role)
	}
	for i := 0; i < len(content.enemies); i += 1 {
		delete(content.enemies[i].name)
		delete(content.enemies[i].resistance)
	}
	content^ = {}
}

unload_level_content :: proc(levels: ^[MAX_LEVELS]Level_Def) {
	for i := 0; i < MAX_LEVELS; i += 1 {
		delete(levels[i].name)
		levels[i] = {}
	}
}

tower_type_from_id :: proc(id: string) -> (Tower_Type, bool) {
	switch id {
	case "arrow":  return .Arrow, true
	case "cannon": return .Cannon, true
	case "frost":  return .Frost, true
	case "flame":  return .Flame, true
	}
	return .None, false
}

enemy_type_from_id :: proc(id: string) -> (Enemy_Type, bool) {
	switch id {
	case "grunt":   return .Grunt, true
	case "runner":  return .Runner, true
	case "brute":   return .Brute, true
	case "boss":    return .Boss, true
	case "armored": return .Armored, true
	case "wraith":  return .Wraith, true
	case "siege_beast": return .Siege_Beast, true
	}
	return .Grunt, false
}

damage_type_from_id :: proc(id: string) -> (Damage_Type, bool) {
	switch id {
	case "physical":  return .Physical, true
	case "magic":     return .Magic, true
	case "elemental": return .Elemental, true
	}
	return .Physical, false
}

asset_id_from_name :: proc(name: string) -> (Asset_Id, bool) {
	switch name {
	case "tower_arrow":   return .Tower_Arrow, true
	case "tower_cannon":  return .Tower_Cannon, true
	case "tower_frost":   return .Tower_Frost, true
	case "tower_flame":   return .Tower_Flame, true
	case "enemy_grunt":   return .Enemy_Grunt, true
	case "enemy_runner":  return .Enemy_Runner, true
	case "enemy_brute":   return .Enemy_Brute, true
	case "enemy_boss":    return .Enemy_Boss, true
	case "enemy_armored": return .Enemy_Armored, true
	case "primitive":     return .Count, true
	}
	return .Count, false
}

tower_asset_for_type :: proc(kind: Tower_Type) -> Asset_Id {
	switch kind {
	case .None:
		return .Count
	case .Arrow:  return .Tower_Arrow
	case .Cannon: return .Tower_Cannon
	case .Frost:  return .Tower_Frost
	case .Flame:  return .Tower_Flame
	}
	return .Count
}

enemy_asset_for_type :: proc(kind: Enemy_Type) -> Asset_Id {
	switch kind {
	case .Grunt:   return .Enemy_Grunt
	case .Runner:  return .Enemy_Runner
	case .Brute:   return .Enemy_Brute
	case .Boss:    return .Enemy_Boss
	case .Armored: return .Enemy_Armored
	case .Wraith:  return .Count
	case .Siege_Beast: return .Count
	}
	return .Count
}

color_from_raw :: proc(color: [4]u8) -> rl.Color {
	return rl.Color{color[0], color[1], color[2], color[3]}
}

parse_towers :: proc(contents: string, content: ^Content_Data) -> (bool, string) {
	raw := Raw_Tower_File{}
	parse_err := json.unmarshal_string(contents, &raw, allocator=context.temp_allocator)
	if parse_err != nil { return false, "invalid JSON or unexpected field type" }
	if raw.version != CONTENT_VERSION { return false, "unsupported content version" }
	if len(raw.towers) != 4 { return false, "expected exactly four tower definitions" }

	content.towers = {}
	seen: [5]bool
	for raw_def in raw.towers {
		kind, kind_ok := tower_type_from_id(raw_def.id)
		if !kind_ok { return false, fmt.tprintf("unsupported tower id: %s", raw_def.id) }
		index := int(kind)
		if seen[index] { return false, fmt.tprintf("duplicate tower id: %s", raw_def.id) }
		seen[index] = true

		asset, asset_ok := asset_id_from_name(raw_def.asset)
		if !asset_ok || asset != tower_asset_for_type(kind) {
			return false, fmt.tprintf("invalid asset for tower: %s", raw_def.id)
		}
		damage_type, damage_type_ok := damage_type_from_id(raw_def.damage_type)
		if !damage_type_ok { return false, fmt.tprintf("invalid damage type for tower: %s", raw_def.id) }
		if raw_def.name == "" || raw_def.role == "" || raw_def.color[3] == 0 {
			return false, fmt.tprintf("missing presentation data for tower: %s", raw_def.id)
		}
		if raw_def.cost <= 0 || raw_def.damage <= 0 || raw_def.range <= 0 ||
			raw_def.cooldown <= 0 || raw_def.projectile_spd <= 0 || raw_def.splash_radius < 0 ||
			raw_def.slow_amount < 0 || raw_def.slow_duration < 0 ||
			raw_def.burn_damage < 0 || raw_def.burn_duration < 0 {
			return false, fmt.tprintf("invalid numeric data for tower: %s", raw_def.id)
		}

		content.towers[index] = Tower_Def{
			name = clone_content_string(raw_def.name), cost = raw_def.cost,
			damage = raw_def.damage, range = raw_def.range, cooldown = raw_def.cooldown,
			projectile_spd = raw_def.projectile_spd, splash_radius = raw_def.splash_radius,
			damage_type = damage_type, slow_amount = raw_def.slow_amount,
			slow_duration = raw_def.slow_duration, burn_damage = raw_def.burn_damage,
			burn_duration = raw_def.burn_duration, asset = asset,
			role = clone_content_string(raw_def.role), color = color_from_raw(raw_def.color),
		}
	}

	for kind in Tower_Type {
		if kind == .None { continue }
		if !seen[int(kind)] { return false, "missing tower definition" }
	}
	return true, ""
}

parse_enemies :: proc(contents: string, content: ^Content_Data) -> (bool, string) {
	raw := Raw_Enemy_File{}
	parse_err := json.unmarshal_string(contents, &raw, allocator=context.temp_allocator)
	if parse_err != nil { return false, "invalid JSON or unexpected field type" }
	if raw.version != CONTENT_VERSION { return false, "unsupported content version" }
	if len(raw.enemies) != 7 { return false, "expected exactly seven enemy definitions" }

	content.enemies = {}
	seen: [7]bool
	for raw_def in raw.enemies {
		kind, kind_ok := enemy_type_from_id(raw_def.id)
		if !kind_ok { return false, fmt.tprintf("unsupported enemy id: %s", raw_def.id) }
		index := int(kind)
		if seen[index] { return false, fmt.tprintf("duplicate enemy id: %s", raw_def.id) }
		seen[index] = true

		asset, asset_ok := asset_id_from_name(raw_def.asset)
		if !asset_ok || asset != enemy_asset_for_type(kind) {
			return false, fmt.tprintf("invalid asset for enemy: %s", raw_def.id)
		}
		if raw_def.name == "" || raw_def.resistance == "" || raw_def.color[3] == 0 {
			return false, fmt.tprintf("missing presentation data for enemy: %s", raw_def.id)
		}
		if raw_def.max_hp <= 0 || raw_def.speed <= 0 || raw_def.gold_reward <= 0 ||
			raw_def.lives_damage <= 0 || raw_def.physical_multiplier <= 0 ||
			raw_def.magic_multiplier <= 0 || raw_def.elemental_multiplier <= 0 {
			return false, fmt.tprintf("invalid numeric data for enemy: %s", raw_def.id)
		}

		content.enemies[index] = Enemy_Def{
			name = clone_content_string(raw_def.name), max_hp = raw_def.max_hp,
			speed = raw_def.speed, gold_reward = raw_def.gold_reward,
			lives_damage = raw_def.lives_damage, asset = asset,
			resistance = clone_content_string(raw_def.resistance),
			physical_multiplier = raw_def.physical_multiplier,
			magic_multiplier = raw_def.magic_multiplier,
			elemental_multiplier = raw_def.elemental_multiplier,
			color = color_from_raw(raw_def.color),
		}
	}

	for kind in Enemy_Type {
		if !seen[int(kind)] { return false, "missing enemy definition" }
	}
	return true, ""
}

parse_waves :: proc(contents: string, expected_level: string, level: ^Level_Def) -> (bool, string) {
	raw := Raw_Wave_File{}
	parse_err := json.unmarshal_string(contents, &raw, allocator=context.temp_allocator)
	if parse_err != nil { return false, "invalid JSON or unexpected field type" }
	if raw.version != CONTENT_VERSION { return false, "unsupported content version" }
	if raw.level != expected_level { return false, "wave file has the wrong level id" }
	if len(raw.waves) <= 0 || len(raw.waves) > MAX_WAVES {
		return false, "wave count is outside the supported capacity"
	}

	level.waves = {}
	for raw_wave, wave_index in raw.waves {
		if len(raw_wave.groups) <= 0 || len(raw_wave.groups) > MAX_WAVE_GROUPS {
			return false, fmt.tprintf("wave %d group count is outside the supported capacity", wave_index+1)
		}
		wave := &level.waves[wave_index]
		wave.group_count = len(raw_wave.groups)
		for raw_group, group_index in raw_wave.groups {
			kind, kind_ok := enemy_type_from_id(raw_group.enemy_id)
			if !kind_ok { return false, fmt.tprintf("wave %d references unknown enemy: %s", wave_index+1, raw_group.enemy_id) }
			if raw_group.count <= 0 || raw_group.spawn_interval <= 0 ||
				raw_group.hp_mult <= 0 || raw_group.speed_mult <= 0 {
				return false, fmt.tprintf("wave %d group %d has invalid numeric data", wave_index+1, group_index+1)
			}
			wave.groups[group_index] = Wave_Group{
				enemy_type = kind, count = raw_group.count,
				spawn_interval = raw_group.spawn_interval, hp_mult = raw_group.hp_mult,
				speed_mult = raw_group.speed_mult,
			}
		}
	}
	level.wave_count = len(raw.waves)
	return true, ""
}

parse_map :: proc(contents: string, expected_level: string, level: ^Level_Def) -> (bool, string) {
	raw := Raw_Map_File{}
	parse_err := json.unmarshal_string(contents, &raw, allocator=context.temp_allocator)
	if parse_err != nil { return false, "invalid JSON or unexpected field type" }
	if raw.version != CONTENT_VERSION { return false, "unsupported content version" }
	if raw.level != expected_level { return false, "map file has the wrong level id" }
	if raw.name == "" { return false, "map name is required" }
	if raw.starting_gold <= 0 || raw.starting_lives <= 0 {
		return false, "starting gold and lives must be positive"
	}
	if len(raw.routes) <= 0 || len(raw.routes) > MAX_ROUTES {
		return false, "route count is outside the supported capacity"
	}

	for raw_route, route_index in raw.routes {
		if len(raw_route.points) < 2 || len(raw_route.points) > MAX_PATH_POINTS {
			return false, fmt.tprintf("route %d point count is outside the supported capacity", route_index+1)
		}

		for raw_point, point_index in raw_route.points {
			if raw_point.x < 0 || raw_point.x >= f32(UI_X) ||
				raw_point.y < 0 || raw_point.y >= f32(MAP_H*TILE_SIZE) {
				return false, fmt.tprintf("route %d point %d is outside the map bounds", route_index+1, point_index+1)
			}

			if point_index > 0 {
				previous := raw_route.points[point_index-1]
				if previous.x == raw_point.x && previous.y == raw_point.y {
					return false, fmt.tprintf("route %d has a zero-length segment", route_index+1)
				}
				if previous.x != raw_point.x && previous.y != raw_point.y {
					return false, fmt.tprintf("route %d has a diagonal segment", route_index+1)
				}
			}

		}
	}

	parsed := Level_Def{
		name = clone_content_string(raw.name),
		starting_gold = raw.starting_gold,
		starting_lives = raw.starting_lives,
		route_count = len(raw.routes),
	}
	for raw_route, route_index in raw.routes {
		route := &parsed.routes[route_index]
		route.point_count = len(raw_route.points)
		for raw_point, point_index in raw_route.points {
			route.points[point_index] = vec2(raw_point.x, raw_point.y)
		}
	}

	level^ = parsed
	return true, ""
}

load_content :: proc(g: ^Game) -> bool {
	towers_path := fmt.tprintf("%s/towers.json", CONTENT_DIR)
	enemies_path := fmt.tprintf("%s/enemies.json", CONTENT_DIR)

	tower_contents, tower_read_err := os.read_entire_file_from_path(towers_path, context.temp_allocator)
	if tower_read_err != os.ERROR_NONE {
		fmt.println("Content load failed:", towers_path, "-", os.error_string(tower_read_err))
		return false
	}
	enemy_contents, enemy_read_err := os.read_entire_file_from_path(enemies_path, context.temp_allocator)
	if enemy_read_err != os.ERROR_NONE {
		fmt.println("Content load failed:", enemies_path, "-", os.error_string(enemy_read_err))
		return false
	}

	valid, err := parse_towers(string(tower_contents), &g.content)
	if !valid { fmt.println("Content load failed:", towers_path, "-", err); return false }
	valid, err = parse_enemies(string(enemy_contents), &g.content)
	if !valid { fmt.println("Content load failed:", enemies_path, "-", err); return false }

	map_paths := [MAX_LEVELS]string{
		fmt.tprintf("%s/maps/grasslands.json", CONTENT_DIR),
		fmt.tprintf("%s/maps/forest_pass.json", CONTENT_DIR),
		fmt.tprintf("%s/maps/frozen_road.json", CONTENT_DIR),
		fmt.tprintf("%s/maps/ruined_outskirts.json", CONTENT_DIR),
		fmt.tprintf("%s/maps/ruined_market.json", CONTENT_DIR),
		fmt.tprintf("%s/maps/ruined_keep.json", CONTENT_DIR),
	}
	map_ids := [MAX_LEVELS]string{
		"grasslands", "forest_pass", "frozen_road",
		"ruined_outskirts", "ruined_market", "ruined_keep",
	}
	for i := 0; i < len(map_paths); i += 1 {
		contents, read_err := os.read_entire_file_from_path(map_paths[i], context.temp_allocator)
		if read_err != os.ERROR_NONE {
			fmt.println("Content load failed:", map_paths[i], "-", os.error_string(read_err))
			return false
		}
		valid, err = parse_map(string(contents), map_ids[i], &g.levels[i])
		if !valid {
			fmt.println("Content load failed:", map_paths[i], "-", err)
			return false
		}
	}

	wave_paths := [MAX_LEVELS]string{
		fmt.tprintf("%s/waves/grasslands.json", CONTENT_DIR),
		fmt.tprintf("%s/waves/forest_pass.json", CONTENT_DIR),
		fmt.tprintf("%s/waves/frozen_road.json", CONTENT_DIR),
		fmt.tprintf("%s/waves/ruined_outskirts.json", CONTENT_DIR),
		fmt.tprintf("%s/waves/ruined_market.json", CONTENT_DIR),
		fmt.tprintf("%s/waves/ruined_keep.json", CONTENT_DIR),
	}
	wave_ids := [MAX_LEVELS]string{
		"grasslands", "forest_pass", "frozen_road",
		"ruined_outskirts", "ruined_market", "ruined_keep",
	}
	for i := 0; i < len(wave_paths); i += 1 {
		contents, read_err := os.read_entire_file_from_path(wave_paths[i], context.temp_allocator)
		if read_err != os.ERROR_NONE {
			fmt.println("Content load failed:", wave_paths[i], "-", os.error_string(read_err))
			return false
		}
		valid, err = parse_waves(string(contents), wave_ids[i], &g.levels[i])
		if !valid {
			fmt.println("Content load failed:", wave_paths[i], "-", err)
			return false
		}
	}
	return true
}
