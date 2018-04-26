package backend;

#if hl
typedef NativeTimer = backend.hl.Timer;
#elseif lua
typedef NativeTimer = backend.love.Timer;
#end

abstract Timer(NativeTimer) {
	public static inline function get_time() return NativeTimer.get_time();
	public static inline function get_delta() return NativeTimer.get_delta();
	public static inline function get_fps() return NativeTimer.get_fps();
	public static inline function sleep(s: Float) return NativeTimer.sleep(s);

	public static inline function measure(f: Void->Void): Float {
		var start_time = get_time();
		f();
		return get_time() - start_time;
	}
}
