package backend;

#if cpp
typedef NativeGc = backend.cpp.Gc;
#elseif lua
typedef NativeGc = backend.love.Gc;
#elseif hl
typedef NativeGc = backend.hl.Gc;
#end

#if cppia
private
#end
abstract Gc(NativeGc) {
	/** Run a GC cycle. If `major`, run a complete collection. **/
	public static inline function run(major: Bool) NativeGc.run(major);

	/** GC Memory usage, in KiB. **/
	public static inline function mem_usage(): Int return NativeGc.mem_usage();
	public static inline function disable() NativeGc.disable();
	public static inline function enable() NativeGc.enable();
}
