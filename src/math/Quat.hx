package math;

import haxe.ds.Vector;

typedef AngleAxis = {
	var angle: Float;
	var axis: Vec3;
}

abstract Quat(Vector<FloatType>) {
	public var x(get, set): FloatType;
	public var y(get, set): FloatType;
	public var z(get, set): FloatType;
	public var w(get, set): FloatType;

	public inline function set_x(v: FloatType) {
		this[0] = v;
		return v;
	}
	public inline function set_y(v: FloatType) {
		this[1] = v;
		return v;
	}
	public inline function set_z(v: FloatType) {
		this[2] = v;
		return v;
	}
	public inline function set_w(v: FloatType) {
		this[3] = v;
		return v;
	}

	public inline function get_x() return this[0];
	public inline function get_y() return this[1];
	public inline function get_z() return this[2];
	public inline function get_w() return this[3];

	public inline function toString() {
		var acc = 0.001;
		return '[${Utils.round(x, acc)}, ${Utils.round(y, acc)}, ${Utils.round(z, acc)}, ${Utils.round(w, acc)}]';
	}

	public function new(x: Float = 0, y: Float = 0, z: Float = 0, w: Float = 1) {
		this = new Vector<FloatType>(4);
		this[0] = x;
		this[1] = y;
		this[2] = z;
		this[3] = w;
	}

	public function length(): Float {
		return Math.sqrt(this[0] * this[0] + this[1] * this[1] + this[2] * this[2] + this[3] * this[3]);
	}

	public function normalize() {
		var l = length();
		if (l == 0) {
			this[3] = 1;
			return;
		}
		var inv_len = 1.0 / l;
		this[0] = this[0] * inv_len;
		this[1] = this[1] * inv_len;
		this[2] = this[2] * inv_len;
		this[3] = this[3] * inv_len;
	}

	public inline function identity() {
		this[0] = 0;
		this[1] = 0;
		this[2] = 0;
		this[3] = 1;
	}

	public inline function copy() {
		return new Quat(this[0], this[1], this[2], this[3]);
	}

	@:arrayAccess
	public inline function get(k: Int) {
		return this[k];
	}

	@:arrayAccess
	public inline function set(k: Int, v: FloatType) {
		this[k] = v;
		return v;
	}

	public inline function apply_forward() {
		return mul_vec3(Vec3.forward());
	}

	public function to_euler() {
		return new Vec3(
			Math.atan2(2*this[1]*this[3]-2*this[0]*this[2] , 1 - 2*Math.pow(this[1], 2) - 2*Math.pow(this[2], 2)), // heading
			Math.asin(2*this[0]*this[1] + 2*this[2]*this[3]), // attitude
			Math.atan2(2*this[0]*this[3]-2*this[1]*this[2] , 1 - 2*Math.pow(this[0], 2) - 2*Math.pow(this[2], 2)) // bank
		);
	}

	public static function from_direction(normal: Vec3, ?up: Vec3): Quat {
		var u = up == null? Vec3.up() : up;
		var n = normal.copy();
		n.normalize();

		var a = Vec3.cross(u, n);
		var d = Vec3.dot(u, n);
		return new Quat(a.x, a.y, a.z, d + 1);
	}

	public static function from_euler(eul: Vec3) {
		var heading: Float = eul[0]*0.5;
		var attitude: Float = eul[1]*0.5;
		var bank: Float = eul[2]*0.5;
		var c1 = Math.cos(heading);
		var s1 = Math.sin(heading);
		var c2 = Math.cos(attitude);
		var s2 = Math.sin(attitude);
		var c3 = Math.cos(bank);
		var s3 = Math.sin(bank);
		var c1c2 = c1*c2;
		var s1s2 = s1*s2;
		return new Quat(
			c1c2*s3 + s1s2*c3,
			s1*c2*c3 + c1*s2*s3,
			c1*s2*c3 - s1*c2*s3,
			c1c2*c3 - s1s2*s3
		);
	}

	public function to_angle_axis(): AngleAxis {
		var a = new Quat(this[0], this[1], this[2], this[3]);
		if (a[3] > 1 || a[3] < -1) {
			a.normalize();
		}

		var x: Float = 0;
		var y: Float = 0;
		var z: Float = 0;
		var angle = 2 * Math.acos(a[3]);
		var s = Math.sqrt(1 - a[3] * a[3]);

		if (s < 0.995) {
			x = a[0];
			y = a[1];
			z = a[2];
		}
		else {
			var inv_s = 1/s;
			x = a[0] * inv_s;
			y = a[1] * inv_s;
			z = a[2] * inv_s;
		}

		return {
			angle: angle,
			axis: new Vec3(x, y, z)
		}
	}

	public static inline function inverse(a: Quat) {
		var q = new Quat(-a.x, -a.y, -a.z, a.w);
		q.normalize();
		return q;
	}

	public static function from_angle_axis(angle: Float, axis: Vec3) {
		var s = Math.sin(angle * 0.5);
		var c = Math.cos(angle * 0.5);
		return new Quat(axis[0] * s, axis[1] * s, axis[2] * s, c);
	}

	@:op(A + B)
	public function add(other: Quat) {
		return new Quat(this[0] + other[0], this[1] + other[1], this[2] + other[2], this[3] + other[3]);
	}

	@:op(A - B)
	public function sub(other: Quat) {
		return new Quat(this[0] - other[0], this[1] - other[1], this[2] - other[2], this[3] - other[3]);
	}

	@:op(-A)
	public function neg() {
		return new Quat(-this[0], -this[1], -this[2], -this[3]);
	}

	@:op(A * B)
	public function mul(other: Quat) {
		return new Quat(
			this[0] * other[3] + this[3] * other[0] + this[1] * other[2] - this[2] * other[1],
			this[1] * other[3] + this[3] * other[1] + this[2] * other[0] - this[0] * other[2],
			this[2] * other[3] + this[3] * other[2] + this[0] * other[1] - this[1] * other[0],
			this[3] * other[3] - this[0] * other[0] - this[1] * other[1] - this[2] * other[2]
		);
	}

	@:op(A * B)
	public function mul_vec3(other: Vec3) {
		var qv = new Vec3(this[0], this[1], this[2]);
		var uv = Vec3.cross(qv, other);
		var uuv = Vec3.cross(qv, uv);
		return other + ((uv * this[3]) + uuv) * 2;
	}

	@:op(A * B)
	public function scale(s: Float) {
		return new Quat(this[0] * s, this[1] * s, this[2] * s, this[3] * s);
	}

	public static inline function dot(a: Quat, b: Quat) {
		return a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3];
	}

	public static function lerp(a: Quat, b: Quat, t: Float) {
		var result = a + (b - a) * t;
		result.normalize();
		return result;
	}

	public static function slerp(a: Quat, b: Quat, t: Float) {
		var d = dot(a, b);

		if (d < 0) {
			a = -a;
			d = -d;
		}

		if (d > 0.995) {
			return lerp(a, b, t);
		}

		d = Utils.clamp(d, -1, 1);

		var c = b - a * d;
		c.normalize();

		var theta = Math.acos(d) * t;
		return a * Math.cos(theta) + c * Math.sin(theta);
	}
}
