package math;

private typedef FrustumData = {
	var left: Vec4;
	var right: Vec4;
	var bottom: Vec4;
	var top: Vec4;
	var near: Vec4;
	var far: Null<Vec4>;
}

@:forward
abstract Frustum(FrustumData) {
	public inline function new(data: FrustumData) {
		this = data;
	}
#if lua
	public inline function to_cpml() {
		return {
			left:   { a: this.left[0], b: this.left[1], c: this.left[2], d: this.left[3] },
			right:  { a: this.right[0], b: this.right[1], c: this.right[2], d: this.right[3] },
			bottom: { a: this.bottom[0], b: this.bottom[1], c: this.bottom[2], d: this.bottom[3] },
			top:    { a: this.top[0], b: this.top[1], c: this.top[2], d: this.top[3] },
			near:   { a: this.near[0], b: this.near[1], c: this.near[2], d: this.near[3] },
			far:    { a: this.far[0], b: this.far[1], c: this.far[2], d: this.far[3] }
		};
	}
#end
}
