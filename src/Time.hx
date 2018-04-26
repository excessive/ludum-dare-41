import math.Quat;
import math.Vec3;
import math.Utils;

abstract ClockTime(Float) {
	public static var YEAR_LENGTH_DAYS(get, null): Float;
	static inline function get_YEAR_LENGTH_DAYS() return 40.0;

	public static var DAY_LENGTH_MINUTES(get, null): Float;
	static inline function get_DAY_LENGTH_MINUTES() return 8.0;

	public static var HOURS_PER_MINUTE(get, null): Float;
	static inline function get_HOURS_PER_MINUTE() return 24.0 / DAY_LENGTH_MINUTES;

	public inline function new(v: Float) {
		this = v;
	}

	public inline static function from_hour(v: Float) {
		return new ClockTime(v / HOURS_PER_MINUTE * 60.0);
	}

	public inline function to_hour24f() {
		return this * HOURS_PER_MINUTE / 60.0;
	}

	public inline function to_hour24() {
		return Std.int(this * HOURS_PER_MINUTE / 60.0);
	}

	public inline function to_hour12() {
		var h12 = to_hour24() % 12;
		return h12 == 0 ? 12 : h12;
	}

	public inline function to_minute() {
		return Std.int(this * HOURS_PER_MINUTE) % 60;
	}

	public inline function update(dt: Float) {
		this += dt;
	}

	@:to
	inline function to_float(): Float {
		return this;
	}
}

@:native("GameTime")
class Time {
	static var SEASON_INFLUENCE = 0.5;
	static var TIME_SCALE = 1.0;
	static var time: ClockTime;
	static var day = 1;

	public static var current_day(get, never): Int;
	public static inline function get_current_day() { return day; }

	public static var current_time(get, set): ClockTime;
	public static inline function get_current_time() { return time; }
	public static inline function set_current_time(_t: ClockTime) { time = _t; return _t; }

	public static var sun_direction(default, null): Vec3;
	public static var sun_brightness(default, null): Float;

	public static function init() {
		time = ClockTime.from_hour(10);
		update(0);
	}

	static function wrap_clock() {
		var now: Float = time;

		// reset timer every day.
		while (now >= ClockTime.DAY_LENGTH_MINUTES * 60.0) {
			now -= ClockTime.DAY_LENGTH_MINUTES * 60.0;
			time = new ClockTime(now);
			day += 1;
		}
	}

	static function update_sun() {
		var now: Float = time;
		
		// Sun rises in the east
		var rotation = Quat.from_angle_axis(Utils.rad(-90.0), Vec3.unit_z());
		rotation *= Quat.from_angle_axis(now * (Math.PI * 2) / 60 / ClockTime.DAY_LENGTH_MINUTES, Vec3.unit_x());

		// start at -1 so midnight is down.
		var basis = new Vec3(0, 0, -1);
		basis.normalize();

		sun_direction = rotation * basis;
		sun_direction.z += Math.sin((day / ClockTime.YEAR_LENGTH_DAYS) * Math.PI*2.0) * SEASON_INFLUENCE;
		sun_direction.normalize();

		sun_brightness = Math.pow(Utils.clamp(Vec3.dot(sun_direction, Vec3.up()) + 0.35, 0, 1), 3);
	}

	public static function update(dt: Float) {
		if (GameInput.locked) {
			return;
		}
		time.update(dt * TIME_SCALE);
		wrap_clock();
		update_sun();
	}
}
