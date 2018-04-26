package math;

@:publicFields
class Plane {
	var origin: Vec3;
	var normal: Vec3;
	var equation: Vec4;

	function new(a: Vec3, b: Vec3) {
		this.origin = a.copy();
		this.normal = b.copy();
		this.equation = new Vec4(
			b.x, b.y, b.z,
			-Vec3.dot(b, a)
		);
	}

	static function from_triangle(a: Vec3, b: Vec3, c: Vec3) {
		var ba = b - a;
		var ca = c - a;

		var temp = Vec3.cross(ba, ca);
		temp.normalize();

		return new Plane(a, temp);
	}

	inline function signed_distance(base_point: Vec3) {
		return Vec3.dot(base_point, this.normal) + this.equation[3];
	}

	inline function is_front_facing(direction: Vec3): Bool {
		return Vec3.dot(this.normal, direction) <= 0.0;
	}
}
