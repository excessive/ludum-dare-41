package backend.love;

import lua.Lua;
import lua.Lua.CollectGarbageOption;

class Gc {
	/** Run a GC cycle. If `major`, run a complete collection. **/
	public static function run(major: Bool) {
		if (major) {
			Lua.collectgarbage(CollectGarbageOption.Collect);
		}
		else {
			Lua.collectgarbage(CollectGarbageOption.Step, 25);
		}
	}

	/** GC Memory usage, in KiB. **/
	public static function mem_usage() {
		return Lua.collectgarbage(CollectGarbageOption.Count);
	}

	public static function disable() {
		Lua.collectgarbage(CollectGarbageOption.Stop);
	}

	public static function enable() {
		Lua.collectgarbage(CollectGarbageOption.Restart);
	}
}
