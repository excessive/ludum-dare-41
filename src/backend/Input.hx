package backend;

#if cpp
typedef NativeInput = backend.cpp.Input;
#elseif lua
typedef NativeInput = backend.love.Input;
#elseif hl
typedef NativeInput = backend.hl.Input;
#end

abstract Input(NativeInput) {
	public static inline function get_mouse_moved(consume: Bool = false): { x: Float, y: Float } {
		return NativeInput.get_mouse_moved(consume);
	}
	public static inline function set_relative(enabled: Bool): Void {
		return NativeInput.set_relative(enabled);
	}
	public static inline function get_relative(): Bool {
		return NativeInput.get_relative();
	}
	public static inline function get_mouse_pos(): { x: Float, y: Float } {
		return NativeInput.get_mouse_pos();
	}
	public static inline function is_down(key: String): Bool {
		return NativeInput.is_down(key);
	}
}
