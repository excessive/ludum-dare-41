package backend;

#if lua
import backend.love.Profiler as NativeProfiler;
#elseif hl
import backend.hl.Profiler as NativeProfiler;
#end

abstract SegmentColor(Array<Float>) {
	public inline function new(r, g, b) {
		this = [r, g, b];
	}

	public var r(get, never): Float;
	public var g(get, never): Float;
	public var b(get, never): Float;

	public inline function get_r() return this[0];
	public inline function get_g() return this[1];
	public inline function get_b() return this[2];

	public static var Render = new SegmentColor(1.0, 0.0, 0.0);
	public static var Default = new SegmentColor(0.0, 0.5, 1.0);
	public static var Player = new SegmentColor(1.0, 0.5, 0.0);
	public static var Animation = new SegmentColor(1.0, 0.0, 0.5);
	public static var World = new SegmentColor(0.25, 0.5, 0.25);
}

abstract Profiler(NativeProfiler) {
	public static inline function load_zone() return NativeProfiler.load_zone();
	public static inline function start_frame() return NativeProfiler.start_frame();
	public static inline function end_frame() return NativeProfiler.end_frame();
	public static inline function marker(label: String, ?color: SegmentColor, ?pos: haxe.PosInfos) return NativeProfiler.marker(label, color, pos);
	public static inline function push_block(label: String, ?color: SegmentColor, ?pos: haxe.PosInfos) return NativeProfiler.push_block(label, color, pos);
	public static inline function pop_block() return NativeProfiler.pop_block();
}
