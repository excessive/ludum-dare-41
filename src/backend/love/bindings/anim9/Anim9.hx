package anim9;

import iqm.IqmAnim;
import lua.Lua;
import lua.Lua.NextResult;
import lua.Table;
import lua.Table.AnyTable;
import lua.TableTools;

typedef Anim9Anim = {
	var name: String;
	// var frames    = {},
	var length: Int;
	var framerate: Float;
	var loop: Bool;
	var markers: Table<Int, String>;
}

typedef Anim9Track = {
	var name: String;
	var offset: Float;
	var weight: Float;
	var rate: Float;
	var callback: Null<Void->Void>;
	var lock: Bool;
	var early: Bool;
	var playing: Bool;
	var active: Bool;
	var frame: Int;
	var marker: Int;
	var blend: Float;
	var base: Float;
}

class FakePairs<T> {
	var t: AnyTable;
	var i: Int = 1;
	var result: Dynamic;
	public inline function new(_t: AnyTable) {
		t = _t;
	}
	public inline function hasNext() {
		result = Lua.next(t, i);
		return result != null;
	}
	public inline function next(): T {
		return cast result.value;
	}
}

class FakeIPairs<T> {
	var t: AnyTable;
	var i: Int = 1;
	var max: Int;
	public inline function new(_t: AnyTable) {
		t = _t;
		max = TableTools.maxn(t);
	}
	public inline function hasNext() {
		return i <= max;
	}
	public inline function next(): T {
		return cast this.t[i++];
	}
}

@:luaRequire("anim9")
extern class Anim9 {
	var current_pose: AnyTable;
	var current_matrices: AnyTable;
	@:native("timeline")
	var internal_timeline: AnyTable;
	var animations: Table<String, Anim9Anim>;
	function new(data: IqmAnim);
	function new_track(name: String, weight: Float = 1, rate: Float = 1, ?callback: Void->Void, lock: Bool = false, early: Bool = false): Null<Anim9Track>;
	function add_animation(data: Dynamic): Void;
	function play(track: Anim9Track): Void;
	function stop(track: Anim9Track): Void;
	function reset(clear_locked: Bool = false): Void;
	function transition(track: Anim9Track, length: Float = 0.2): Void;
	function find_track(track: Anim9Track): Bool;
	function update(dt: Float): Void;
	function find_index(bone_name: String): Int;
	function length(name: String): Float;
	inline function iter_tracks(): FakeIPairs<Anim9Track> {
		return new FakeIPairs(this.internal_timeline);
	}
	inline function iter_animations(): FakePairs<Anim9Anim> {
		return new FakePairs(this.animations);
	}
}
