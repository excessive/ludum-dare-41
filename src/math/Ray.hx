package math;

class Ray {
	public var position: Vec3;
	public var direction: Vec3;

	public inline function new(p: Vec3, d: Vec3) {
		this.position  = p;
		this.direction = d;
	}
}
