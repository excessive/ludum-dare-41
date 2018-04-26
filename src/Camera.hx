import math.Vec3;
import math.Quat;
import math.Mat4;
import math.Utils;
import math.Triangle;

class Camera {
	public var tilt:          Quat  = new Quat(0, 0, 0, 1);
	public var last_tilt:     Quat;

	public var fov:           Float = 70;
	public var orbit_offset:  Vec3  = new Vec3(0, -1.5, 0);
	public var offset:        Vec3  = new Vec3(0, 0, -4);
	public var position:      Vec3  = new Vec3(0, 0, 0);
	public var last_position: Vec3;
	public var target:        Vec3;
	public var last_target:   Vec3;
	public var orientation:   Quat  = new Quat(0, 0, 0, 1);
	public var direction:     Vec3  = new Vec3(0, 1, 0);
	public var view:          Mat4  = new Mat4();
	public var projection:    Mat4  = new Mat4();
	public var clip_distance: Float = 999;
	public var near:          Float = 1.0;
	public var far:           Float = 1000.0;
	public var viewable:      Triangle;

	var clip_minimum: Float = 4;
	var clip_bias:    Float = 3;

	var up    = Vec3.up();
	var right = Vec3.right();

	var mouse_sensitivity: Float = 0.2;
	var pitch_limit_up:    Float = 0.9;
	var pitch_limit_down:  Float = 0.9;

	public function new(position: Vec3) {
		this.position  = position;
		this.target    = position + new Vec3(0.0, 0.01, 0);
		this.direction = this.orientation.apply_forward();
		this.last_position = this.position.copy();
		this.last_target   = this.target.copy();
		this.last_tilt     = this.tilt.copy();
	}

	public function rotate_xy(mx: Float, my: Float) {
		var sensitivity = this.mouse_sensitivity;
		var mouse_direction = {
			x: Utils.rad(-mx * sensitivity),
			y: Utils.rad(-my * sensitivity)
		};

		// get the axis to rotate around the x-axis.
		var axis = Vec3.cross(this.direction, this.up);
		axis.normalize();

		// First, we apply a left/right rotation.
		this.orientation = Quat.from_angle_axis(mouse_direction.x, this.up) * this.orientation;

		// Next, we apply up/down rotation.
		// up/down rotation is applied after any other rotation (so that other rotations are not affected by it),
		// hence we post-multiply it.
		var new_orientation = this.orientation * Quat.from_angle_axis(mouse_direction.y, this.right);
		var new_pitch       = Vec3.dot(-new_orientation.apply_forward(), this.up);

		// Don't rotate up/down more than this.pitch_limit.
		// We need to limit pitch, but the only reliable way we're going to get away with this is if we
		// calculate the new orientation twice. If the new rotation is going to be over the threshold and
		// Y will send you out any further, cancel it out. This prevents the camera locking up at +/-PITCH_LIMIT
		if (new_pitch >= this.pitch_limit_up) {
			mouse_direction.y = Math.min(0, mouse_direction.y);
		}
		else if (new_pitch <= -this.pitch_limit_down) {
			mouse_direction.y = Math.max(0, mouse_direction.y);
		}

		this.orientation = this.orientation * Quat.from_angle_axis(mouse_direction.y, this.right);

		// Apply rotation to camera direction
		this.direction = this.orientation.apply_forward();
	}

	function frustum_triangle(w: Float, h: Float) {
		var aspect = Math.max(w / h, h / w);
		var aspect_inv = Math.min(w / h, h / w);
		var fovy = Utils.rad(this.fov * aspect_inv);

		var hheight = Math.tan(fovy/2);
		var hwidth: Float = hheight * aspect;
		var cam_right = Vec3.cross(this.direction, this.up);

		var far_clip = this.far;
		var adjusted = this.position;
		var far_center = adjusted + this.direction * far_clip;
		var far_right  = cam_right * hwidth * far_clip;
		var far_top    = this.up * hheight * far_clip;

		var fbl = far_center - far_right - far_top;
		var ftl = far_center - far_right + far_top;

		var fbr = far_center + far_right - far_top;
		var ftr = far_center + far_right + far_top;

		var use_top = Vec3.distance(adjusted, ftl) > Vec3.distance(adjusted, fbl);

		return new Triangle(
			use_top? ftr : fbr,
			use_top? ftl : fbl,
			// far_center  + far_right  - far_top,
			// far_center  - far_right  - far_top,
			adjusted,
			new Vec3(0, 0, 0)
		);
	}

	inline function real_position(mix: Float): Vec3 {
		var pos = this.position;
		if (mix < 1.0) {
			pos = Vec3.lerp(this.last_position, this.position, mix);
		}
		return pos;
	}

	inline function real_target(mix: Float): Vec3 {
		var tgt = this.target;
		if (mix < 1.0) {
			tgt = Vec3.lerp(this.last_target, this.target, mix);
		}
		return tgt;
	}

	inline function real_tilt(mix: Float): Quat {
		var tlt = this.tilt;
		if (mix < 1.0) {
			tlt = Quat.slerp(this.last_tilt, this.tilt, mix);
		}
		return tlt;
	}

	public function update(w: Float, h: Float, mix: Float = 1.0) {
		var aspect = Math.max(w / h, h / w);
		var aspect_inv = Math.min(w / h, h / w);
		var pos = real_position(mix);
		var target = real_target(mix) + new Vec3(0, 0, this.orbit_offset.y / 4);

		var clip = -(Math.max(this.clip_distance, this.clip_minimum) - this.clip_bias);
		clip = Math.max(this.offset.z, clip);

		var tilt = Quat.slerp(real_tilt(mix), new Quat(0, 0, 0, 1), 0.85);

		var orbit = Mat4.translate(this.orbit_offset);
		var look = Mat4.look_at(pos, target, this.up, tilt);
		var offset = Mat4.translate(new Vec3(this.offset.x, this.offset.y, clip));
		this.view = offset * orbit * look;

		var fovy = this.fov * aspect_inv;
		this.projection = Mat4.from_perspective(fovy, aspect, this.near, this.far);
		this.viewable = frustum_triangle(w, h);

		// var vp = this.projection * this.view;
		// World.update_visible(this.viewable, vp.to_frustum());
	}
}
