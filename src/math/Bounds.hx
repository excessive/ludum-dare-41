package math;

@:publicFields
class Bounds {
	var center: Vec3;
	var size: Vec3;
	var min: Vec3;
	var max: Vec3;

	function new(center: Vec3, size: Vec3) {
		this.center = center;
		this.size   = size;
		this.min    = center - (size / 2);
		this.max    = center + (size / 2);
	}

	static function from_extents(min: Vec3, max: Vec3) {
		var size = max - min;
		var center = min + size / 2;
		return new Bounds(center, size);
	}
}
