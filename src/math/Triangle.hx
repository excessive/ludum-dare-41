package math;

class Triangle {
#if 1
	public var v0(get, set): Vec3;
	public var v1(get, set): Vec3;
	public var v2(get, set): Vec3;
	public var vn(get, set): Vec3;

	public inline function get_v0_scaled(scale: Vec3) return new Vec3(v0_x * scale.x, v0_y * scale.y, v0_z * scale.z);
	public inline function get_v1_scaled(scale: Vec3) return new Vec3(v1_x * scale.x, v1_y * scale.y, v1_z * scale.z);
	public inline function get_v2_scaled(scale: Vec3) return new Vec3(v2_x * scale.x, v2_y * scale.y, v2_z * scale.z);
	public inline function get_vn_scaled(scale: Vec3) return new Vec3(vn_x * scale.x, vn_y * scale.y, vn_z * scale.z);

	public inline function get_v0() return new Vec3(v0_x, v0_y, v0_z);
	public inline function get_v1() return new Vec3(v1_x, v1_y, v1_z);
	public inline function get_v2() return new Vec3(v2_x, v2_y, v2_z);
	public inline function get_vn() return new Vec3(vn_x, vn_y, vn_z);

	public inline function set_v0(v: Vec3) {
		v0_x = v.x;
		v0_y = v.y;
		v0_z = v.z;
		return v;
	}

	public inline function set_v1(v: Vec3) {
		v1_x = v.x;
		v1_y = v.y;
		v1_z = v.z;
		return v;
	}

	public inline function set_v2(v: Vec3) {
		v2_x = v.x;
		v2_y = v.y;
		v2_z = v.z;
		return v;
	}

	public inline function set_vn(v: Vec3) {
		vn_x = v.x;
		vn_y = v.y;
		vn_z = v.z;
		return v;
	}

	var v0_x: FloatType;
	var v0_y: FloatType;
	var v0_z: FloatType;

	var v1_x: FloatType;
	var v1_y: FloatType;
	var v1_z: FloatType;

	var v2_x: FloatType;
	var v2_y: FloatType;
	var v2_z: FloatType;

	var vn_x: FloatType;
	var vn_y: FloatType;
	var vn_z: FloatType;
#else
	public var v0: Vec3;
	public var v1: Vec3;
	public var v2: Vec3;
	public var vn: Vec3;

	public inline function get_v0_scaled(scale: Vec3) return v0 * scale;
	public inline function get_v1_scaled(scale: Vec3) return v1 * scale;
	public inline function get_v2_scaled(scale: Vec3) return v2 * scale;
	public inline function get_vn_scaled(scale: Vec3) return vn * scale;
#end

	public static inline function without_normal(a, b, c) {
		return new Triangle(
			a, b, c,
			_normal(a, b, c)
		);
	}

	public inline function new(a: Vec3, b: Vec3, c: Vec3, n: Vec3) {
		v0 = a;
		v1 = b;
		v2 = c;
		vn = n;
	}

	public inline function min() {
		var min = Vec3.min(v0, v1);
		min.x = Utils.min(min.x, v2.x);
		min.y = Utils.min(min.y, v2.y);
		min.z = Utils.min(min.z, v2.z);
		return min;
	}

	public inline function max() {
		var max = Vec3.max(v0, v1);
		max.x = Utils.max(max.x, v2.x);
		max.y = Utils.max(max.y, v2.y);
		max.z = Utils.max(max.z, v2.z);
		return max;
	}

	static function _normal(v0: Vec3, v1: Vec3, v2: Vec3): Vec3 {
		var ba = v1 - v0;
		var ca = v2 - v0;
		var n = Vec3.cross(ba, ca);
		n.normalize();
		return n;
	}

	public inline function normal() {
		return _normal(this.v0, this.v1, this.v2);
	}
}
