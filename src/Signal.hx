typedef TimerHandle = {
	time: Float,
	callback: Void->Void
}

class Signal {
	static var signals = new Map<String, Array<Dynamic->Void>>();
	static var delays  = new Array<TimerHandle>();

	public static function register(event: String, fn: Dynamic->Void) {
		if (!signals.exists(event)) {
			signals[event] = [];
		}
		signals[event].push(fn);
	}

	public static function unregister(event: String, fn: Dynamic->Void) {
		if (!signals.exists(event)) {
			return;
		}
		var cbs = signals[event];
		var idx = cbs.indexOf(fn);
		if (idx >= 0) {
			cbs.splice(idx, 1);
		}
	}

	public static function emit(event: String, ?data: Dynamic) {
		if (!signals.exists(event)) {
			return;
		}
		var cbs = signals[event];
		for (cb in cbs) {
			cb(data);
		}
	}

	public static inline function after(seconds: Float, fn: Void->Void) {
		delays.push({
			time: seconds,
			callback: fn
		});
		return delays[delays.length-1];
	}

	public static inline function cancel(handle: TimerHandle) {
		if (handle == null) {
			return;
		}
		delays.remove(handle);
	}

	public static function update(dt: Float) {
		if (GameInput.locked) {
			return;
		}
		var i = delays.length;
		while (i-- > 0) {
			var timer = delays[i];
			timer.time -= dt;
			if (timer.time <= 0) {
				timer.callback();
				delays.splice(i, 1);
			}
		}
	}
}
