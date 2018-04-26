package render;

import math.Mat4;
import love.graphics.Mesh;

typedef DrawCommand = {
	var xform_mtx: Mat4;
	var normal_mtx: Mat4;
	var mesh: Mesh;
	var triplanar: Bool;
	@:optional var bones: Array<Mat4>;
}
