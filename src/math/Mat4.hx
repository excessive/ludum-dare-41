package math;

#if lua
import lua.Table;
#end

#if 0
abstract Mat4(Table<Int, FloatType>) {
	public inline function new(?data: Array<Float>) {
		if (data == null) {
			this = untyped __lua__("{
				[0] = 1.0, 0.0, 0.0, 0.0,
				0.0, 1.0, 0.0, 0.0,
				0.0, 0.0, 1.0, 0.0,
				0.0, 0.0, 0.0, 1.0
			}");
		}
		else {
			this = untyped __lua__("{0}", data);
		}
	}
#else
abstract Mat4(Array<FloatType>) {
	public inline function new(?data: Array<Float>) {
		if (data == null) {
			this = [
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1
			];
		}
		else {
			this = [ for (i in 0...16) data[i] ];
		}
	}
#end

	public inline function to_array(): Array<FloatType> {
		return this;
	}

	public function identity() {
		for (i in 0...16) {
			this[i] = 0;
		}
		for (i in 0...3) {
			this[i+i*4] = 1;
		}
	}

	public static function scale(s: Vec3) {
		return new Mat4([
			s.x, 0, 0, 0,
			0, s.y, 0, 0,
			0, 0, s.z, 0,
			0, 0, 0, 1
		]);
	}

	public static function translate(t: Vec3) {
		return new Mat4([
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			t.x, t.y, t.z, 1
		]);
	}

	public static inline function rotate(q: Quat) {
		var a = q.to_angle_axis();
		return from_angle_axis(a.angle, a.axis);
	}

	public static function from_srt(translate: Vec3, rotate: Quat, scale: Vec3) {
#if MAT4_PREMUL
		return Mat4.scale(scale)
			* Mat4.rotate(rotate)
			* Mat4.translate(translate)
		;
#else
		return Mat4.translate(translate)
			* Mat4.rotate(rotate)
			* Mat4.scale(scale)
		;
#end

		var _tx = translate.x;
		var _ty = translate.y;
		var _tz = translate.z;

		var r = rotate.to_euler();
		var _ax = r.x;
		var _ay = r.y;
		var _az = r.z;

		var _sx = scale.x;
		var _sy = scale.y;
		var _sz = scale.z;

		var sx = Math.sin(_ax), sy = Math.sin(_ay), sz = Math.sin(_az);
		var cx = Math.cos(_ax), cy = Math.cos(_ay), cz = Math.cos(_az);

		var sxsz = sx*sz;
		var cycz = cy*cz;

		return new Mat4([
			_sx * (cycz - sxsz*sy), _sx * -cx*sz, _sx * (cz*sy + cy*sxsz), 0.0,
			_sy * (cz*sx*sy + cy*sz), _sy * cx*cz, _sy * (sy*sz -cycz*sx), 0.0,
			_sz * -cx*sy, _sz * sx, _sz * cx*cy, 0.0,
			_tx, _ty, _tz, 1.0
		]);
	}

	public static function look_at2(eye: Vec3, at: Vec3, up: Vec3) {
		var forward = (eye - at);
		forward.normalize();
		
		// Check if look direction is parallel to the up vector, if so, shuffle up vector elements
		if ((forward + up) == new Vec3(0, 0, 0)) {
			up *= 0;
		}
		
		var z_axis = forward;
		var x_axis = Vec3.cross(up , z_axis);
		x_axis.normalize();
		var y_axis = Vec3.cross(z_axis, x_axis);
		
		return new Mat4([
			x_axis.x, y_axis.x, z_axis.x, 0,
			x_axis.y, y_axis.y, z_axis.y, 0,
			x_axis.z, y_axis.z, z_axis.z, 0,
			eye.x, eye.y, eye.z, 1
		]);
	}

	public static function look_at(eye: Vec3, at: Vec3, up: Vec3, ?tilt: Quat) {
		var forward = at - eye;
		if (tilt != null) {
			forward = tilt * forward;
			up = tilt * up;
		}
		forward.normalize();
		var side = Vec3.cross(forward, up);
		side.normalize();
		var new_up = Vec3.cross(side, forward);

		return new Mat4([
			side.x, new_up.x, -forward.x, 0,
			side.y, new_up.y, -forward.y, 0,
			side.z, new_up.z, -forward.z, 0,
			-Vec3.dot(side, eye), -Vec3.dot(new_up, eye), Vec3.dot(forward, eye), 1
		]);
	}

	public static function inverse(a: Mat4): Mat4 {
		var out: Mat4 = a.copy();
		out.invert();
		return out;
	}

	public function invert() {
		var out = new Mat4([
			 this[5] * this[10] * this[15] - this[5] * this[11] * this[14] - this[9]  * this[6] * this[15] + this[9]  * this[7] * this[14] + this[13] * this[6] * this[11] - this[13] * this[7] * this[10],
			-this[1] * this[10] * this[15] + this[1] * this[11] * this[14] + this[9]  * this[2] * this[15] - this[9]  * this[3] * this[14] - this[13] * this[2] * this[11] + this[13] * this[3] * this[10],
			 this[1] * this[6]  * this[15] - this[1] * this[7]  * this[14] - this[5]  * this[2] * this[15] + this[5]  * this[3] * this[14] + this[13] * this[2] * this[7]  - this[13] * this[3] * this[6],
			-this[1] * this[6]  * this[11] + this[1] * this[7]  * this[10] + this[5]  * this[2] * this[11] - this[5]  * this[3] * this[10] - this[9]  * this[2] * this[7]  + this[9]  * this[3] * this[6],
			-this[4] * this[10] * this[15] + this[4] * this[11] * this[14] + this[8]  * this[6] * this[15] - this[8]  * this[7] * this[14] - this[12] * this[6] * this[11] + this[12] * this[7] * this[10],
			 this[0] * this[10] * this[15] - this[0] * this[11] * this[14] - this[8]  * this[2] * this[15] + this[8]  * this[3] * this[14] + this[12] * this[2] * this[11] - this[12] * this[3] * this[10],
			-this[0] * this[6]  * this[15] + this[0] * this[7]  * this[14] + this[4]  * this[2] * this[15] - this[4]  * this[3] * this[14] - this[12] * this[2] * this[7]  + this[12] * this[3] * this[6],
			 this[0] * this[6]  * this[11] - this[0] * this[7]  * this[10] - this[4]  * this[2] * this[11] + this[4]  * this[3] * this[10] + this[8]  * this[2] * this[7]  - this[8]  * this[3] * this[6],
			 this[4] * this[9]  * this[15] - this[4] * this[11] * this[13] - this[8]  * this[5] * this[15] + this[8]  * this[7] * this[13] + this[12] * this[5] * this[11] - this[12] * this[7] * this[9],
			-this[0] * this[9]  * this[15] + this[0] * this[11] * this[13] + this[8]  * this[1] * this[15] - this[8]  * this[3] * this[13] - this[12] * this[1] * this[11] + this[12] * this[3] * this[9],
			 this[0] * this[5]  * this[15] - this[0] * this[7]  * this[13] - this[4]  * this[1] * this[15] + this[4]  * this[3] * this[13] + this[12] * this[1] * this[7]  - this[12] * this[3] * this[5],
			-this[0] * this[5]  * this[11] + this[0] * this[7]  * this[9]  + this[4]  * this[1] * this[11] - this[4]  * this[3] * this[9]  - this[8]  * this[1] * this[7]  + this[8]  * this[3] * this[5],
			-this[4] * this[9]  * this[14] + this[4] * this[10] * this[13] + this[8]  * this[5] * this[14] - this[8]  * this[6] * this[13] - this[12] * this[5] * this[10] + this[12] * this[6] * this[9],
			 this[0] * this[9]  * this[14] - this[0] * this[10] * this[13] - this[8]  * this[1] * this[14] + this[8]  * this[2] * this[13] + this[12] * this[1] * this[10] - this[12] * this[2] * this[9],
			-this[0] * this[5]  * this[14] + this[0] * this[6]  * this[13] + this[4]  * this[1] * this[14] - this[4]  * this[2] * this[13] - this[12] * this[1] * this[6]  + this[12] * this[2] * this[5],
			 this[0] * this[5]  * this[10] - this[0] * this[6]  * this[9]  - this[4]  * this[1] * this[10] + this[4]  * this[2] * this[9]  + this[8]  * this[1] * this[6]  - this[8]  * this[2] * this[5]
		]);

		var det: FloatType = this[0] * out[0] + this[1] * out[4] + this[2] * out[8] + this[3] * out[12];

		if (det == 0) {
			return;
		}

		det = 1 / det;

		for (i in 0...16) {
			this[i] = out[i] * det;
		}
	}

	public function transpose() {
#if lua
		var tmp = [ for (i in 0...16) this[i] ];
#else
		var tmp = this.copy();
#end
		this[1]  = tmp[4];
		this[2]  = tmp[8];
		this[3]  = tmp[12];
		this[4]  = tmp[1];
		this[6]  = tmp[9];
		this[7]  = tmp[13];
		this[8]  = tmp[2];
		this[9]  = tmp[6];
		this[11] = tmp[14];
		this[12] = tmp[3];
		this[13] = tmp[7];
		this[14] = tmp[11];
	}

	public static function from_angle_axis(angle: Float, axis: Vec3) {
		var l = axis.lengthsq();
		if (l == 0) {
			return new Mat4();
		}
		l = Math.sqrt(l);

		var x = axis.x / l;
		var y = axis.y / l;
		var z = axis.z / l;
		var c = Math.cos(angle);
		var s = Math.sin(angle);

		return new Mat4([
			x*x*(1-c)+c,   y*x*(1-c)+z*s, x*z*(1-c)-y*s, 0,
			x*y*(1-c)-z*s, y*y*(1-c)+c,   y*z*(1-c)+x*s, 0,
			x*z*(1-c)+y*s, y*z*(1-c)-x*s, z*z*(1-c)+c,   0,
			0, 0, 0, 1
		]);
	}

	public static function from_ortho(left: Float, right: Float, top: Float, bottom: Float, near: Float, far: Float) {
		return new Mat4([
			2 / (right - left), 0, 0, 0,
			0, 2 / (top - bottom), 0, 0,
			0, 0, -2 / (far - near), 0,
			-((right + left) / (right - left)), -((top + bottom) / (top - bottom)), -((far + near) / (far - near)), 1
		]);
	}

	public static function from_perspective(fovy: Float, aspect: Float, near: Float, far: Float) {
		var t = Math.tan(Utils.rad(fovy) / 2);
		return new Mat4([
			1 / (t * aspect), 0, 0, 0,
			0, 1 / t, 0, 0,
			0, 0, -(far + near) / (far - near), -1,
			0, 0,  -(2 * far * near) / (far - near), 0
		]);
	}

	public function set_clips(near: Float, far: Float) {
		this[10] = -(far + near) / (far - near);
		this[14] = -(2 * far * near) / (far - near);
	}

#if lua
	public static function from_cpml(t: lua.Table<Int, Float>) {
		return new Mat4([
			t[1], t[2], t[3], t[4],
			t[5], t[6], t[7], t[8],
			t[9], t[10], t[11], t[12],
			t[13], t[14], t[15], t[16]
		]);
	}
#end

	public static inline function bias(amount: Float = 0.0) {
		return new Mat4([
			0.5, 0.0, 0.0, 0.0,
			0.0, 0.5, 0.0, 0.0,
			0.0, 0.0, 0.5, 0.0,
			0.5, 0.5, 0.5, 1.0 + amount
		]);
	}

	public function copy() {
		var out = new Mat4();
		for (i in 0...16) {
			out[i] = this[i];
		}
		return out;
	}

#if lua
	public function to_vec4s(): Table<Int, Table<Int, Float>> {
		return untyped __lua__("{
			{ {0}[0], {0}[4],  {0}[8], {0}[12]  },
			{ {0}[1], {0}[5],  {0}[9], {0}[13]  },
			{ {0}[2], {0}[6], {0}[10], {0}[14] },
			{ {0}[3], {0}[7], {0}[11], {0}[15] }
		}", this);
	}

	public function to_vec4s_transposed() {
		var a = this;
		untyped __lua__("
			do return {
				{ a[0],  a[1],  a[2],  a[3]  },
				{ a[4],  a[5],  a[6],  a[7]  },
				{ a[8],  a[9],  a[10], a[11] },
				{ a[12], a[13], a[14], a[15] }
			} end
		");
		return Table.create();
	}
#end

	public function to_frustum_corners() {
		var inv = Mat4.inverse(cast this);

		return [
			inv * new Vec3(-1,  1, -1),
			inv * new Vec3( 1,  1, -1),
			inv * new Vec3( 1, -1, -1),
			inv * new Vec3(-1, -1, -1),
			inv * new Vec3(-1,  1, 1),
			inv * new Vec3( 1,  1, 1),
			inv * new Vec3( 1, -1, 1),
			inv * new Vec3(-1, -1, 1)
		];
	}

	public function to_frustum(infinite: Bool = false) {
		// Extract the LEFT plane
		var left = new Vec4(
			this[3]  + this[0],
			this[7]  + this[4],
			this[11] + this[8],
			this[15] + this[12]
		);
		left.normalize();

		// Extract the RIGHT plane
		var right = new Vec4(
			this[3]  - this[0],
			this[7]  - this[4],
			this[11] - this[8],
			this[15] - this[12]
		);
		right.normalize();

		// Extract the BOTTOM plane
		var bottom = new Vec4(
			this[3]  + this[1],
			this[7]  + this[5],
			this[11] + this[9],
			this[15] + this[13]
		);
		bottom.normalize();

		// Extract the TOP plane
		var top = new Vec4(
			this[3]  - this[1],
			this[7]  - this[5],
			this[11] - this[9],
			this[15] - this[13]
		);
		top.normalize();

		// Extract the NEAR plane
		var near = new Vec4(
			this[3]  + this[2],
			this[7]  + this[6],
			this[11] + this[10],
			this[15] + this[14]
		);
		near.normalize();

		var far = null;
		if (!infinite) {
			// Extract the FAR plane
			far = new Vec4(
				this[3]  - this[2],
				this[7]  - this[6],
				this[11] - this[10],
				this[15] - this[14]
			);
			far.normalize();
		}

		return new Frustum({
			left: left,
			right: right,
			bottom: bottom,
			top: top,
			near: near,
			far: far
		});
	}

	@:arrayAccess
	public inline function get(k: Int): Float {
		return this[k];
	}

	@:arrayAccess
	public inline function set(k: Int, v: Float) {
		this[k] = v;
		return v;
	}

#if MAT4_PREMUL
	@:op(A * B)
#end
	public function mul(b: Mat4) {
		var out = new Mat4();
		var a = this;
		// Sys.exit(1);
		out[0]  = a[0]  * b[0] + a[1]  * b[4] + a[2]  *  b[8] +  a[3] * b[12];
		out[1]  = a[0]  * b[1] + a[1]  * b[5] + a[2]  *  b[9] +  a[3] * b[13];
		out[2]  = a[0]  * b[2] + a[1]  * b[6] + a[2]  * b[10] +  a[3] * b[14];
		out[3]  = a[0]  * b[3] + a[1]  * b[7] + a[2]  * b[11] +  a[3] * b[15];
		out[4]  = a[4]  * b[0] + a[5]  * b[4] + a[6]  *  b[8] +  a[7] * b[12];
		out[5]  = a[4]  * b[1] + a[5]  * b[5] + a[6]  *  b[9] +  a[7] * b[13];
		out[6]  = a[4]  * b[2] + a[5]  * b[6] + a[6]  * b[10] +  a[7] * b[14];
		out[7]  = a[4]  * b[3] + a[5]  * b[7] + a[6]  * b[11] +  a[7] * b[15];
		out[8]  = a[8]  * b[0] + a[9]  * b[4] + a[10] *  b[8] + a[11] * b[12];
		out[9]  = a[8]  * b[1] + a[9]  * b[5] + a[10] *  b[9] + a[11] * b[13];
		out[10] = a[8]  * b[2] + a[9]  * b[6] + a[10] * b[10] + a[11] * b[14];
		out[11] = a[8]  * b[3] + a[9]  * b[7] + a[10] * b[11] + a[11] * b[15];
		out[12] = a[12] * b[0] + a[13] * b[4] + a[14] *  b[8] + a[15] * b[12];
		out[13] = a[12] * b[1] + a[13] * b[5] + a[14] *  b[9] + a[15] * b[13];
		out[14] = a[12] * b[2] + a[13] * b[6] + a[14] * b[10] + a[15] * b[14];
		out[15] = a[12] * b[3] + a[13] * b[7] + a[14] * b[11] + a[15] * b[15];
		return out;
	}

#if !MAT4_PREMUL
	@:op(A * B)
#end
	public function mul_post(b: Mat4) {
		var out = new Mat4();
		var a = this;
#if MAT4_REFERENCE
		Sys.exit(0);
		inline function A(row,col) return a[(col<<2)+row];
		inline function B(row,col) return b[(col<<2)+row];
		inline function P(row,col) return (col<<2)+row;

		for (i in 0...4) {
			var ai0 = A(i,0), ai1=A(i,1), ai2=A(i,2), ai3=A(i,3);
			out[P(i,0)] = ai0 * B(0,0) + ai1 * B(1,0) + ai2 * B(2,0) + ai3 * B(3,0);
			out[P(i,1)] = ai0 * B(0,1) + ai1 * B(1,1) + ai2 * B(2,1) + ai3 * B(3,1);
			out[P(i,2)] = ai0 * B(0,2) + ai1 * B(1,2) + ai2 * B(2,2) + ai3 * B(3,2);
			out[P(i,3)] = ai0 * B(0,3) + ai1 * B(1,3) + ai2 * B(2,3) + ai3 * B(3,3);
		}
#else
		out[0]  = b[0]  * a[0] + b[1]  * a[4] + b[2]  *  a[8] +  b[3] * a[12];
		out[1]  = b[0]  * a[1] + b[1]  * a[5] + b[2]  *  a[9] +  b[3] * a[13];
		out[2]  = b[0]  * a[2] + b[1]  * a[6] + b[2]  * a[10] +  b[3] * a[14];
		out[3]  = b[0]  * a[3] + b[1]  * a[7] + b[2]  * a[11] +  b[3] * a[15];
		out[4]  = b[4]  * a[0] + b[5]  * a[4] + b[6]  *  a[8] +  b[7] * a[12];
		out[5]  = b[4]  * a[1] + b[5]  * a[5] + b[6]  *  a[9] +  b[7] * a[13];
		out[6]  = b[4]  * a[2] + b[5]  * a[6] + b[6]  * a[10] +  b[7] * a[14];
		out[7]  = b[4]  * a[3] + b[5]  * a[7] + b[6]  * a[11] +  b[7] * a[15];
		out[8]  = b[8]  * a[0] + b[9]  * a[4] + b[10] *  a[8] + b[11] * a[12];
		out[9]  = b[8]  * a[1] + b[9]  * a[5] + b[10] *  a[9] + b[11] * a[13];
		out[10] = b[8]  * a[2] + b[9]  * a[6] + b[10] * a[10] + b[11] * a[14];
		out[11] = b[8]  * a[3] + b[9]  * a[7] + b[10] * a[11] + b[11] * a[15];
		out[12] = b[12] * a[0] + b[13] * a[4] + b[14] *  a[8] + b[15] * a[12];
		out[13] = b[12] * a[1] + b[13] * a[5] + b[14] *  a[9] + b[15] * a[13];
		out[14] = b[12] * a[2] + b[13] * a[6] + b[14] * a[10] + b[15] * a[14];
		out[15] = b[12] * a[3] + b[13] * a[7] + b[14] * a[11] + b[15] * a[15];
#end

		return out;
	}

	public static function flip_yz() {
		return new Mat4([
			1, 0, 0, 0,
			0, 0,-1, 0,
			0, 1, 0, 0,
			0, 0, 0, 1
		]);
	}

	@:op(A * B)
	public function mul_vec3(b: Vec3) {
		var a: Mat4 = cast this;
		return new Vec3(
			b.x * a[0] + b.y * a[4] + b.z * a[8]  + a[12],
			b.x * a[1] + b.y * a[5] + b.z * a[9]  + a[13],
			b.x * a[2] + b.y * a[6] + b.z * a[10] + a[14]
		);
	}

	public function mul_vec3_w1(b: Vec3) {
		return new Vec4(
			b.x * this[0] + b.y * this[4] + b.z * this[8]  + this[12],
			b.x * this[1] + b.y * this[5] + b.z * this[9]  + this[13],
			b.x * this[2] + b.y * this[6] + b.z * this[10] + this[14],
			b.x * this[3] + b.y * this[7] + b.z * this[11] + this[15]
		);
	}

	public function mul_vec3_w0(b: Vec3) {
		return new Vec4(
			b.x * this[0] + b.y * this[4] + b.z * this[8],
			b.x * this[1] + b.y * this[5] + b.z * this[9],
			b.x * this[2] + b.y * this[6] + b.z * this[10],
			b.x * this[3] + b.y * this[7] + b.z * this[11]
		);
	}

	public function mul_vec3_perspective(b: Vec3) {
		var a: Mat4 = cast this;
		var b4 = a.mul_vec3_w1(b);
		// var inv_w = 1.0 / b4.w;
		var inv_w = Utils.sign(b4.w)/b4.w;
		return new Vec3(b4.x * inv_w, b4.y * inv_w, b4.z * inv_w);
	}

	@:op(A * B)
	public function mul_array(b: Array<Float>) {
		var a: Mat4 = cast this;
		return a * new Vec3(b[0], b[1], b[2]);
	}

	@:op(A * B)
	public function mul_vec4(b: Vec4) {
		return new Vec4(
			b.x * this[0] + b.y * this[4] + b.z * this[8]  + this[12] * b.w,
			b.x * this[1] + b.y * this[5] + b.z * this[9]  + this[13] * b.w,
			b.x * this[2] + b.y * this[6] + b.z * this[10] + this[14] * b.w,
			b.x * this[3] + b.y * this[7] + b.z * this[11] + this[15] * b.w
		);
	}

	public function equal(that: Mat4) {
		for (i in 0...16) {
			if (Math.abs(this[i] - that[i]) > 1.0e-5) {
				return false;
			}
		}
		return true;
	}

	public static function coalesce(matrices: Array<Mat4>): Array<FloatType> {
		var buffer: Array<FloatType> = [];
		for (m in matrices) {
			buffer = buffer.concat(m.to_array());
		}
		return buffer;
	}
}
