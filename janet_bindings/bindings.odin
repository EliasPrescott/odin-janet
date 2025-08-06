package janet

import "core:c"
import "core:fmt"
import "core:slice"

when ODIN_OS == .Darwin do foreign import janet "../janet/build/libjanet.a"

JanetAtomicInt :: int

JanetType :: enum c.int {
    NUMBER,
    NIL,
    BOOLEAN,
    FIBER,
    STRING,
    SYMBOL,
    KEYWORD,
    ARRAY,
    TUPLE,
    TABLE,
    STRUCT,
    BUFFER,
    FUNCTION,
    CFUNCTION,
    ABSTRACT,
    POINTER
}

JanetValueUnion :: struct #raw_union {
		_u64: u64,
		number: f64,
		integer: i32,
		pointer: rawptr,
		cpointer: rawptr,
}

Janet :: struct {
		as: JanetValueUnion,
		type: JanetType,
}

JanetBuffer :: struct {
		gc: JanetGCObject,
		count: i32,
		capacity: i32,
		data: [^]u8,
}

JanetGCObjectData :: struct #raw_union {
		next: ^JanetGCObject,
		refcount: JanetAtomicInt,
}

JanetGCObject :: struct {
		flags: i32,
		data: JanetGCObjectData,
}

JanetKV :: struct {
		key: Janet,
		value: Janet,
}

JanetTable :: struct {
		gc: JanetGCObject,
		count: i32,
		capacity: i32,
		deleted: i32,
		data: [^]JanetKV,
		proto: ^JanetTable,
}

JanetString :: cstring

@(link_prefix="janet_", require_results)
foreign janet {
		init :: proc() ---
		deinit :: proc() ---
		core_env :: proc(replacements: rawptr) -> ^JanetTable ---
		dostring :: proc(env: [^]JanetTable, str: cstring, source_path: cstring, out: rawptr) -> int ---
		to_string :: proc(x: Janet) -> JanetString ---

		// wrapping functions
		wrap_nil :: proc() -> Janet ---
		wrap_number :: proc(x: f64) -> Janet ---
		wrap_true :: proc() -> Janet ---
		wrap_false :: proc() -> Janet ---
		wrap_boolean :: proc(x: c.int) -> Janet ---
		wrap_string :: proc(x: cstring) -> Janet ---
		wrap_symbol :: proc(x: cstring) -> Janet ---
		wrap_keyword :: proc(x: cstring) -> Janet ---
		// wrap_array :: proc(JanetArray *x) -> Janet ---
		// wrap_tuple :: proc(const Janet *x) -> Janet ---
		// wrap_struct :: proc(const JanetKV *x) -> Janet ---
		// wrap_fiber :: proc(JanetFiber *x) -> Janet ---
		wrap_buffer :: proc(x: ^JanetBuffer) -> Janet ---
		// wrap_function :: proc(JanetFunction *x) -> Janet ---
		// wrap_cfunction :: proc(JanetCFunction x) -> Janet ---
		wrap_table :: proc(x: ^JanetTable) -> Janet ---
		// wrap_abstract :: proc(void *x) -> Janet ---
		// wrap_pointer :: proc(void *x) -> Janet ---
		wrap_integer :: proc(x: i32) -> Janet ---

		// table API
		table :: proc(capacity: i32) -> ^JanetTable ---
		table_put :: proc(t: ^JanetTable, key: Janet, value: Janet) ---

		// buffer API
		buffer :: proc(capacity: i32) -> ^JanetBuffer ---
		pretty :: proc(buffer: ^JanetBuffer, depth: c.int, flags: c.int, x: Janet) -> ^JanetBuffer ---
}

janet_buf_to_slice :: proc(buffer: ^JanetBuffer) -> []u8 {
		fmt.println(buffer)
		return slice.bytes_from_ptr(buffer.data, int(buffer.count))
}
