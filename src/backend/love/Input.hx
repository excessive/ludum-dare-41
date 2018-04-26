package backend.love;

import love.mouse.MouseModule as Mouse;
import love.keyboard.KeyboardModule as Keyboard;

class Input {
	public static var mx:  Float = 0;
	public static var my:  Float = 0;

	public static function get_mouse_moved(consume: Bool) {
		var _mx = mx;
		var _my = my;
		if (consume) {
			mx = 0;
			my = 0;
		}
		return { x: _mx, y: _my };
	}

	public static function get_mouse_pos() {
		var pos = Mouse.getPosition();
		return { x: pos.x, y: pos.y };
	}

	public static inline function is_down(key: String) {
		return Keyboard.isDown(key);
	}

	public static inline function set_relative(enabled: Bool) {
		Mouse.setRelativeMode(enabled);
		GameLoop.was_grabbed = enabled;
	}
	public static inline function get_relative() {
		return GameLoop.was_grabbed;
	}
}
