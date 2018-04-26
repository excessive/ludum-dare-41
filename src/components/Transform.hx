package components;

import math.Quat;
import math.Vec3;
import math.Mat4;

class Transform {
	public var position:      Vec3 = new Vec3();
	public var orientation:   Quat = new Quat(0, 0, 0, 1);
	public var velocity:      Vec3 = new Vec3();
	public var scale:         Vec3 = new Vec3(1, 1, 1);
	public var offset:        Vec3 = new Vec3();
	public var is_static:     Bool = false;
	public var matrix:        Mat4;
	public var normal_matrix: Mat4;

	public inline function new() {}

	public function update() {
		matrix = Mat4.from_srt(position + offset, orientation, scale);

		var inv = Mat4.inverse(matrix);
		inv.transpose();
		normal_matrix = inv;
	}

	public function copy() {
		var ret         = new Transform();
		ret.position    = position.copy();
		ret.orientation = orientation.copy();
		ret.velocity    = velocity.copy();
		ret.offset      = offset.copy();
		ret.scale       = scale.copy();

		return ret;
	}
}
