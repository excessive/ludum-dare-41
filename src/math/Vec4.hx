package math;

import haxe.ds.Vector;

abstract Vec4(Vector<FloatType>) {
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

	public inline function get_x(): FloatType return this[0];
	public inline function get_y(): FloatType return this[1];
	public inline function get_z(): FloatType return this[2];
	public inline function get_w(): FloatType return this[3];

	public function new(a: FloatType = 0, b: FloatType = 0, c: FloatType = 0, d: FloatType = 0) {
		this = new Vector(4);

		this[0] = a;
		this[1] = b;
		this[2] = c;
		this[3] = d;
	}

	@:arrayAccess
	public inline function get(k: Int) {
		return this[k];
	}

	@:arrayAccess
	public inline function set(k: Int, v: FloatType) {
		this[k] = v;
	}

	public inline function copy() {
		return new Vec4(this[0], this[1], this[2], this[3]);
	}

	public inline function w_div() {
		var w = this[3];
		var inv_w = 1.0/w;
		if (w == 0) {
			inv_w = 1.0;
		}
		return new Vec3(this[0] * inv_w, this[1] * inv_w, this[2] * inv_w);
	}

	public function normalize() {
		var l = this[0] * this[0] + this[1] * this[1] + this[2] * this[2] + this[3] * this[3];
		if (l == 0) {
			return;
		}
		l = Math.sqrt(l);
		for (i in 0...4) {
			this[i] /= l;
		}
	}
}
