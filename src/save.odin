package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Save_Version :: 1

Saved_Level_Result :: struct {
	completed:  bool,
	best_score: int,
	best_lives: int,
}

Save_Data :: struct {
	levels: [MAX_LEVELS]Saved_Level_Result,
}

results_file_path :: proc() -> (string, bool) {
	base, err := os.user_data_dir(context.allocator, true)
	if err != os.ERROR_NONE {
		fmt.println("Could not resolve the user data directory:", os.error_string(err))
		return "", false
	}

	path, path_err := os.join_path({base, "Rune Siege TD", "results.txt"}, context.allocator)
	if path_err != nil {
		fmt.println("Could not build the results path:", path_err)
		return "", false
	}
	return path, true
}

playtest_log_path :: proc() -> (string, bool) {
	base, err := os.user_data_dir(context.allocator, true)
	if err != os.ERROR_NONE {
		fmt.println("Could not resolve the user data directory:", os.error_string(err))
		return "", false
	}

	path, path_err := os.join_path({base, "Rune Siege TD", "playtest_runs.txt"}, context.allocator)
	if path_err != nil {
		fmt.println("Could not build the playtest log path:", path_err)
		return "", false
	}
	return path, true
}

playtest_outcome_name :: proc(g: ^Game) -> string {
	if g.mode == .Victory { return "VICTORY" }
	return "DEFEAT"
}

log_playtest_result :: proc(g: ^Game) {
	if g.playtest_logged || (g.mode != .Victory && g.mode != .Defeat) { return }
	path, ok := playtest_log_path()
	if !ok { return }

	existing := ""
	contents, read_err := os.read_entire_file_from_path(path, context.temp_allocator)
	if read_err == os.ERROR_NONE {
		existing = string(contents)
	} else if os.exists(path) {
		fmt.println("Could not read the playtest log:", os.error_string(read_err))
		return
	}

	builder := strings.builder_make()
	defer strings.builder_destroy(&builder)
	fmt.sbprintf(&builder, "%sRUN level=%d name=\"%s\" outcome=%s score=%d lives=%d gold=%d towers=%d\n",
		existing, g.current_level+1, g.levels[g.current_level].name, playtest_outcome_name(g),
		g.result_score, max(g.lives, 0), g.gold, g.tower_count)
	for i := 0; i < g.tower_count; i += 1 {
		t := g.towers[i]
		def := get_tower_def(g, t.kind)
		fmt.sbprintf(&builder, "TOWER kind=%s tile=%d,%d level=%d\n", def.name, t.tile_x, t.tile_y, t.level)
	}
	fmt.sbprintf(&builder, "END\n")

	log := strings.to_string(builder)
	directory_err := os.make_directory_all(os.dir(path))
	if directory_err != os.ERROR_NONE {
		fmt.println("Could not create the playtest log directory:", os.error_string(directory_err))
		return
	}
	write_err := os.write_entire_file_from_string(path, log)
	if write_err != os.ERROR_NONE {
		fmt.println("Could not save the playtest log:", os.error_string(write_err))
		return
	}
	g.playtest_logged = true
}

load_results :: proc(level_count: int) -> Save_Data {
	data := Save_Data{}
	path, ok := results_file_path()
	if !ok { return data }

	contents, err := os.read_entire_file_from_path(path, context.temp_allocator)
	if err != os.ERROR_NONE {
		if os.exists(path) { fmt.println("Could not read saved results:", os.error_string(err)) }
		return data
	}

	parsed, valid := parse_results(string(contents), level_count)
	if !valid { fmt.println("Saved results are malformed; starting with empty results.") }
	return parsed
}

parse_results :: proc(contents: string, level_count: int) -> (Save_Data, bool) {
	data := Save_Data{}
	lines, split_err := strings.split_lines(contents, context.temp_allocator)
	if split_err != nil || len(lines) == 0 { return data, false }

	header := strings.split(strings.trim(lines[0], " \t\r\n"), " ", context.temp_allocator)
	if len(header) != 2 || header[0] != "RUNE_SIEGE_RESULTS" {
		return data, false
	}
	version, version_ok := strconv.parse_int(header[1])
	if !version_ok || version != Save_Version { return data, false }

	for raw_line in lines[1:] {
		line := strings.trim(raw_line, " \t\r\n")
		if line == "" { continue }
		fields, fields_err := strings.split(line, " ", context.temp_allocator)
		if fields_err != nil || len(fields) != 4 { return Save_Data{}, false }

		level, level_ok := strconv.parse_int(fields[0])
		score, score_ok := strconv.parse_int(fields[1])
		lives, lives_ok := strconv.parse_int(fields[2])
		completed, completed_ok := strconv.parse_bool(fields[3])
		if !level_ok || !score_ok || !lives_ok || !completed_ok ||
			level < 0 || level >= min(level_count, MAX_LEVELS) ||
			score < 0 || lives < 0 {
			return Save_Data{}, false
		}

		data.levels[level] = Saved_Level_Result{completed, score, lives}
	}

	return data, true
}

serialize_results :: proc(data: ^Save_Data, level_count: int) -> string {
	builder := strings.builder_make()
	fmt.sbprintf(&builder, "RUNE_SIEGE_RESULTS %d\n", Save_Version)
	count := min(level_count, MAX_LEVELS)
	for level := 0; level < count; level += 1 {
		record := data.levels[level]
		fmt.sbprintf(&builder, "%d %d %d %t\n", level, record.best_score, record.best_lives, record.completed)
	}
	result := strings.to_string(builder)
	cloned, clone_err := strings.clone(result, context.temp_allocator)
	strings.builder_destroy(&builder)
	if clone_err != nil { return "" }
	return cloned
}

save_results :: proc(data: ^Save_Data, level_count: int) {
	path, ok := results_file_path()
	if !ok { return }

	directory_err := os.make_directory_all(os.dir(path))
	if directory_err != os.ERROR_NONE {
		fmt.println("Could not create the results directory:", os.error_string(directory_err))
		return
	}

	err := os.write_entire_file_from_string(path, serialize_results(data, level_count))
	if err != os.ERROR_NONE {
		fmt.println("Could not save results:", os.error_string(err))
	}
}

update_best_result :: proc(data: ^Save_Data, level_index, score, lives: int) -> bool {
	if level_index < 0 || level_index >= MAX_LEVELS { return false }
	record := &data.levels[level_index]
	changed := !record.completed || score > record.best_score || lives > record.best_lives
	if !changed { return false }

	record.completed = true
	if score > record.best_score { record.best_score = score }
	if lives > record.best_lives { record.best_lives = lives }
	return true
}
