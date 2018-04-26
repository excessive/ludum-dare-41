package math;

class Capsule {
	public var a: Vec3;
	public var b: Vec3;
	public var radius: FloatType;

	public function new(a: Vec3, b: Vec3, radius: Float) {
		this.a = a;
		this.b = b;
		this.radius = radius;
	}
}
