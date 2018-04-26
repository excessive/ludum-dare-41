package ui;

import backend.Window;

class Anchor {
	// Helper utilities for positioning things relative to screen anchor points and
	// dealing with overscan.
	//
	// Use the default instance or make a new one with anchor.new(params) or using
	// anchor(params). You can control X and Y offset and padding for all 4 edges.
	//
	// This library does not retain state for screen dimensions, so resizing should
	// be perfectly fine.
	static var x_offset: Int = 0;
	static var y_offset: Int = 0;
	static var padding_left: Int = 0;
	static var padding_right: Int = 0;
	static var padding_top: Int = 0;
	static var padding_bottom: Int = 0;
	static var overscan: Float = 0.1;
	static var _width: Float;
	static var _height: Float;

	public static function update(wnd: Window) {
		var size = wnd.get_size();
		_width  = size.width;
		_height = size.height;

		padding_left   = Math.floor(_width * (overscan / 2));
		padding_right  = padding_left;

		padding_top    = Math.floor(_height * (overscan / 2));
		padding_bottom = padding_top;
	}

	public static function set_overscan(amount) {
		overscan = amount;
	}

	public static var top(get, null): Int;
	public static var bottom(get, null): Int;
	public static var left(get, null): Int;
	public static var right(get, null): Int;
	public static var width(get, null): Int;
	public static var height(get, null): Int;
	public static var center_x(get, null): Int;
	public static var center_y(get, null): Int;

	static function get_top(): Int {
		return y_offset + padding_top;
	}

	static function get_bottom(): Int {
		return Std.int(_height + y_offset - padding_bottom);
	}

	static function get_left(): Int {
		return Std.int(x_offset + padding_left);
	}

	static function get_right(): Int {
		return Std.int(_width + x_offset - padding_right);
	}

	static inline function get_width(): Int {
		return get_right() - get_left();
	}

	static inline function get_height(): Int {
		return get_bottom() - get_top();
	}

	static inline function get_center_x(): Int {
		return Std.int((get_left() + get_right()) / 2);
	}

	static inline function get_center_y(): Int {
		return Std.int((get_top() + get_bottom()) / 2);
	}
}
