package math;

// NB: Use .x/y/z indexing internally! It's needed for target specific fixups
// since Lua likes 1-indexing on tables.

#if lua
abstract Vec3(lua.Table<Int, FloatType>) {
#else
abstract Vec3(Vector<FloatType>) {
#end
	public var x(get, set): FloatType;
	public var y(get, set): FloatType;
	public var z(get, set): FloatType;

#if lua
	public inline function get_x() return this[1];
	public inline function get_y() return this[2];
	public inline function get_z() return this[3];

	public inline function set_x(v: FloatType) {
		this[1] = v;
		return v;
	}
	public inline function set_y(v: FloatType) {
		this[2] = v;
		return v;
	}
	public inline function set_z(v: FloatType) {
		this[3] = v;
		return v;
	}

	@:arrayAccess public inline function get(k: Int): FloatType return this[k+1];
	@:arrayAccess public inline function set(k: Int, v: FloatType) this[k+1] = v;
#else
	public inline function get_x() return this[0];
	public inline function get_y() return this[1];
	public inline function get_z() return this[2];

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

	@:arrayAccess public inline function get(k: Int): FloatType return this[k];
	@:arrayAccess public inline function set(k: Int, v: FloatType) this[k] = v;
#end

#if lua
	public function new(x: Float = 0, y: Float = 0, z: Float = 0) {
		this = lua.Table.create([ x, y, z ]);
	}
#else
	public inline function new(x: Float = 0, y: Float = 0, z: Float = 0) {
		this = new Vector<FloatType>(3);

		this[0] = x;
		this[1] = y;
		this[2] = z;
	}
#end

	public static inline function unit_x() {
		return new Vec3(1, 0, 0);
	}

	public static inline function unit_y() {
		return new Vec3(0, 1, 0);
	}

	public static inline function unit_z() {
		return new Vec3(0, 0, 1);
	}

	public static inline function forward() {
		return new Vec3(0, -1, 0);
	}

	public static inline function right() {
		return unit_x();
	}

	public static inline function up() {
		return unit_z();
	}

	@:op(A + B)
	public inline function add(b: Vec3) {
		var a: Vec3 = cast this;
		return new Vec3(a.x + b.x, a.y + b.y, a.z + b.z);
	}

	@:op(A - B)
	public inline function sub(b: Vec3) {
		var a: Vec3 = cast this;
		return new Vec3(a.x - b.x, a.y - b.y, a.z - b.z);
	}

	@:op(A / B)
	public inline function div(b: Vec3) {
		var a: Vec3 = cast this;
		return new Vec3(a.x / b.x, a.y / b.y, a.z / b.z);
	}

	@:op(A * B)
	public inline function mul(b: Vec3) {
		var a: Vec3 = cast this;
		return new Vec3(a.x * b.x, a.y * b.y, a.z * b.z);
	}

	@:op(A * B)
	public inline function mul_array(b: Array<Float>) {
		var a: Vec3 = cast this;
		return new Vec3(a.x * b[0], a.y * b[1], a.z * b[2]);
	}

	@:op(A / B)
	public inline function fdiv(b: Float) {
		var a: Vec3 = cast this;
		return new Vec3(a.x / b, a.y / b, a.z / b);
	}

	@:op(A * B)
	public inline function scale(b: Float) {
		var a: Vec3 = cast this;
		return new Vec3(a.x * b, a.y * b, a.z * b);
	}

	@:op(-A)
	public inline function neg() {
		return scale(-1);
	}

	@:op(A == B)
	public function eq(b: Vec3) {
		var a: Vec3 = cast this;
		var threshold = 0.0001;
		return Vec3.near(a, b, threshold);
	}

	public static inline function near(a: Vec3, b: Vec3, threshold: Float): Bool {
		return Vec3.distance(a, b) < threshold;
	}

	public function length() {
		var self: Vec3 = cast this;
		return Math.sqrt(self.lengthsq());
	}

	public inline function lengthsq() {
		var self: Vec3 = cast this;
		return self.x * self.x + self.y * self.y + self.z * self.z;
	}

	public function normalize() {
		var a: Vec3 = cast this;
		var l = a.lengthsq();
		if (l == 0) {
			return;
		}
		l = Math.sqrt(l);
		a.x /= l;
		a.y /= l;
		a.z /= l;
	}

	public static function cross(a: Vec3, b: Vec3) {
		return new Vec3(
			a.y * b.z - a.z * b.y,
			a.z * b.x - a.x * b.z,
			a.x * b.y - a.y * b.x
		);
	}

	public static inline function distance(a: Vec3, b: Vec3) {
		var dx = a.x - b.x;
		var dy = a.y - b.y;
		var dz = a.z - b.z;
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}

	/** returns true if vector was trimmed **/
	public function trim(max_len: Float): Bool {
		var self: Vec3 = cast this;
		var len = Math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
		if (len > max_len) {
			var inv_len = 1.0 / len;
			self.x *= inv_len;
			self.y *= inv_len;
			self.z *= inv_len;
			self.x *= max_len;
			self.y *= max_len;
			self.z *= max_len;
			return true;
		}
		return false;
	}

	public static function min(a: Vec3, b: Vec3) {
		return new Vec3(
			Utils.min(a.x, b.x),
			Utils.min(a.y, b.y),
			Utils.min(a.z, b.z)
		);
	}

	public static function max(a: Vec3, b: Vec3) {
		return new Vec3(
			Utils.max(a.x, b.x),
			Utils.max(a.y, b.y),
			Utils.max(a.z, b.z)
		);
	}

	public static inline function dot(a: Vec3, b: Vec3) {
		return a.x * b.x + a.y * b.y + a.z * b.z;
	}

	public inline function copy() {
		var self: Vec3 = cast this;
		return new Vec3(self.x, self.y, self.z);
	}

	public static function lerp(low: Vec3, high: Vec3, progress: Float): Vec3 {
		return low + (high - low) * progress;
	}

	public static function project_on(a: Vec3, b: Vec3): Vec3 {
		var s = dot(a, b) / dot(b, b);

		return new Vec3(
			b.x * s,
			b.y * s,
			b.z * s
		);
	}

	public static function reflect(i: Vec3, n: Vec3): Vec3 {
		return i - (n * (2 * dot(n, i)));
	}

#if lua
	public inline function unpack(): lua.Table<Int, FloatType> {
		return this;
	}
#end
}
