package main

import "core:fmt"
import "core:unicode"
import "core:strings"

import rl "vendor:raylib"

import janet "./janet_bindings"

AppState :: struct {
		input: strings.Builder,
		output: [dynamic]u8,
}

dump_table :: proc(table: ^janet.JanetTable) {
        for i := 0; i32(i) < table.count; i = i + 1 {
                if table.data[i].key.type == .NIL do continue
                env_buf := janet.pretty(nil, 3, 0, table.data[i].key)
                fmt.println(string(janet.janet_buf_to_slice(env_buf)))
                env_buf2 := janet.pretty(nil, 3, 0, table.data[i].value)
                fmt.println(string(janet.janet_buf_to_slice(env_buf2)))
                i = i + 1
        }
}

main :: proc() {
		janet.init()
		defer janet.deinit()

		env := janet.core_env(nil)

		rl.InitWindow(800, 800, "ignore")
		rl.SetTargetFPS(60)

		state: AppState

		eval :: proc(env: ^janet.JanetTable, input: cstring, output: ^[dynamic]u8) {
                value := new(janet.Janet)
                res := janet.dostring(env, input, "main", value)
                buf := janet.pretty(nil, 3, 0, value^)
                dump_table(env)
				append(output, string(janet.janet_buf_to_slice(buf)))
		}

		for !rl.WindowShouldClose() {
				char := rl.GetCharPressed()
				if is_valid_char(char) {
						if rl.IsKeyDown(.LEFT_SHIFT) && rl.IsKeyDown(.RIGHT_SHIFT) {
								char = unicode.to_lower(char)
						}
						strings.write_rune(&state.input, char)
				}

				if rl.IsKeyPressed(.BACKSPACE) && strings.builder_len(state.input) > 0 {
						strings.pop_rune(&state.input)
				}

				if rl.IsKeyPressed(.ENTER) && strings.builder_len(state.input) > 0 {
						input := strings.to_cstring(&state.input)
						strings.builder_reset(&state.input)
						append(&state.output, "\n")
						fmt.println(input)
						eval(env, input, &state.output)
				}

				rl.ClearBackground(rl.RAYWHITE)

				text := strings.clone_to_cstring(string(state.output[:]))
				rl.DrawText(text, 12, 12, 24, rl.BLACK)

				draw_input_box(&state)

				rl.EndDrawing()
		}
}

is_valid_char :: proc(char: rune) -> bool {
		keycode := int(char)
		valid := false
		switch char {
		case '(', ')': valid = true
		case:
				if keycode >= 0x0020 && keycode <= 0x007e {
						valid = true
				}
		}
		if !valid && keycode != 0 {
				fmt.println(char)
		}
		return valid
}

draw_input_box :: proc(state: ^AppState) {
		text := strings.to_cstring(&state.input)
		rl.DrawText(text, 12, 724, 24, rl.BLACK)
}
