import love.graphics.GraphicsModule as Lg;
import backend.Timer;
import ui.Anchor;
import math.Utils;

typedef MenuEntry = {
	label: String,
	title: Bool,
	leader: Bool,
	pause: Bool,
	small: Bool,
	fail: Bool,
	action: Void->Void
}

class Menu {
	// disable unpausing (triggered on stage time out)
	static var locked: Bool = false;
	// relock immediately after buffer runs out to
	// make frame advancing easier.
	static var relock: Bool = false;
	static var buffer: Float = 0.0;

	public static var title_mode(default, null): Bool = false;
	static var leader_mode: Bool = false;
	static var fail_mode: Bool = false;
	static var pause_mode(get, never): Bool;
	static function get_pause_mode() {
		return (!title_mode && !leader_mode && !fail_mode);
	}

	static var options: Array<MenuEntry> = [
		{ label: "Continue", small: false, pause: true, fail: false, title: false, leader: false, action: function() {
			locked = false;
			if (fail_mode) {
				Sfx.bonk.stop();
				Sfx.bonk.play();
				return;
			}
			buffer_unlock();
		} },
		{ label: "Retry", small: false, pause: true, fail: true, title: false, leader: false, action: function() {
			// TODO: restart CURRENT stage, not into next
			if (Stage.stop_time && !fail_mode) {
				Sfx.bonk.stop();
				Sfx.bonk.play();
				return;
			}
			fail_mode = false;
			buffer_unlock();
			Signal.emit("respawn");
		} },
		{ label: "Give Up", small: false, pause: true, fail: true, title: false, leader: true, action: function() {
			Main.stage_data = [];
			title_mode = true;
			leader_mode = false;
			fail_mode = false;
			Signal.emit("surrender");
		} },
		{ label: "Again!", small: false, pause: false, fail: false, title: false, leader: true, action: function() {
			Main.stage_data = [];
			title_mode = false;
			leader_mode = false;
			fail_mode = false;
			locked = false;
			buffer_unlock();
		} },
		{ label: "Start", small: false, pause: false, fail: false, title: true, leader: false, action: function() {
			title_mode = false;
			leader_mode = false;
			fail_mode = false;
			locked = false;
			buffer_unlock();
		} },
		{ label: "Exit", small: false, pause: false, fail: false, title: true, leader: false, action: function() {
			love.event.EventModule.quit();
		} },
	];


	static var selected: MenuEntry;

	static inline function format(fmt: String, args: Array<Dynamic>): String {
		var _real = untyped __lua__("{}");
		for (i in 0...args.length) {
			untyped __lua__("table.insert({0}, {1})", _real, args[i]);
		}
		return untyped __lua__("string.format({0}, unpack({1}))", fmt, _real);
	}

	public static function buffer_unlock() {
		buffer = 1/15;

		if (Stage.time_elapsed == 0) {
			Signal.emit("hud-ready");
		}
	}

	public static function title_lock() {
		GameInput.lock();
		title_mode = true;
		locked = true;
	}

	public static function fail_lock() {
		GameInput.lock();
		fail_mode = true;
		locked = true;
	}

	public static function leader_lock() {
		GameInput.lock();
		leader_mode = true;
		locked = true;
	}

	static function selectable(): Array<MenuEntry> {
		var ret = [];
		for (o in options) {
			if (  (o.title  == title_mode  && title_mode)
				|| (o.leader == leader_mode && leader_mode)
				|| (o.pause  == pause_mode  && pause_mode)
				|| (o.fail   == fail_mode   && fail_mode)
			) {
				ret.push(o);
			}
		}

		if (leader_mode) {
			var total = 0.0;

			for (i in 0 ... Main.stage_data.length) {
				var data  = Main.stage_data[i];
				var level = Main.levels[data.stage];
				var label = format("%s - %0.2f", [level.name, data.time]);
				total += data.time;

				ret.push({ label: label, small: true, pause: false, fail: false, title: false, leader: true, action: function() {
					Sfx.bonk.stop();
					Sfx.bonk.play();
					return;
				}});
			}

			var label = format("%s - %0.2f", ["Total Time", total]);
			ret.push({ label: label, small: true, pause: false, fail: false, title: false, leader: true, action: function() {
				Sfx.bonk.stop();
				Sfx.bonk.play();
				return;
			}});
		}

		return ret;
	}

	public static function update(dt: Float) {
		if (relock) {
			relock = false;
			GameInput.lock();
		}

		if (!GameInput.locked) {
			return;
		}

		if (buffer > 0) {
			buffer -= dt;
			if (GameInput.pressed(MenuToggle)) {
				relock = true;
			}
			if (buffer <= 0) {
				GameInput.unlock();
			}
			return;
		}

		if (!locked && (GameInput.pressed(MenuToggle) || GameInput.pressed(MenuCancel))) {
			buffer_unlock();
			return;
		}

		var options = selectable();
		var index = options.indexOf(selected);
		if (index < 0) {
			index = 0;
			selected = options[0];
		}

		if (GameInput.pressed(MenuUp)) {
			index -= 1;
		}
		if (GameInput.pressed(MenuDown)) {
			index += 1;
		}

		index = Std.int(Utils.wrap(index, options.length));
		selected = options[index];

		if (GameInput.pressed(MenuConfirm)) {
			selected.action();
		}
	}

	public static function draw() {
		if (!GameInput.locked || buffer > 0) {
			return;
		}
		var font = Hud.big_font;
		Lg.setFont(font);

		var options = selectable();
		var spacing = font.getHeight() * font.getLineHeight() * 1.5;
		inline function advance(i: Int) {
			return spacing * i;
		}
		var width = 550;
		var height = advance(options.length);

		var x = Anchor.center_x - width / 2;
		var y = Anchor.center_y - height / 2;

		Lg.setColor(0, 0, 0, 0.75);
		Lg.rectangle(Fill, x, y, width, height, 5, 5);

		for (i in 0...options.length) {
			var o = options[i];
			if (selected == o) {
				var time = Std.int(Timer.get_time() * 20);
				var flash = (time % 3 == 0) ? 1 : 0;
				Lg.setColor(1, 0.5 + 0.5 * flash, flash, 1);
			}
			else {
				Lg.setColor(1, 1, 1, 1);
			}
			font = o.small ? Hud.small_font : Hud.big_font;
			Lg.setFont(font);

			var ox = Anchor.center_x - font.getWidth(o.label) / 2;
			var oy = y + advance(i) + spacing / 2 - font.getHeight() / 2;
			Lg.print(o.label, ox, oy);
			Lg.setColor(1, 1, 1, 1);
		}
	}
}
