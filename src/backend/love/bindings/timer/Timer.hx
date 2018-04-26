package timer;

import lua.Table;

typedef WaitFn = Float->Void;
typedef AfterFn = Void->Void;

extern class TimerHandle {}

@:luaRequire("timer")
extern class Timer {
	static function script(script: WaitFn->Void): Void;
	static function update(dt: Float): Void;
	static function after(delay: Float, func: AfterFn->Void): TimerHandle;
	static function every(interval: Float, func: AfterFn, ?repeat: Int): TimerHandle;
	static function during(duration: Float, func: Float->Void, ?after: Void->Void): TimerHandle;
	@:native("tween")
	private static function _tween(len: Float, target: Dynamic, properties: Dynamic, method: TweenMethod, ?after: Void->Void): TimerHandle;
	static inline function tween(len: Float, target: Dynamic, properties: Dynamic, method: TweenMethod, ?after: Void->Void): TimerHandle {
		var props = lua.Table.create();
		var fields = Reflect.fields(properties);
		for (f in fields) {
			untyped __lua__("{0}[{1}] = {2}", props, f, Reflect.field(properties, f));
		}
		return _tween(len, target, props, method, after);
	}
	static function clear(): Void;
	static function cancel(handle: TimerHandle): Void;
}
