package render;

import love.graphics.GraphicsModule as Lg;
import love.graphics.Shader;
import math.Vec3;
import math.Quat;
import math.Mat4;
import math.Utils;

class Helpers {
	public static inline function send(shader: Shader, name: String, data: Dynamic) {
		if (shader.hasUniform(name)) {
			shader.send(name, data);
		}
	}

	public static inline function send_mtx(shader: Shader, name: String, data: Mat4) {
		if (shader.hasUniform(name)) {
			shader.send(name, "column", data.to_vec4s_transposed());
		}
	}

	public static function send_uniforms(camera: Camera, shader: Shader) {
		var w = Lg.getWidth();
		var h = Lg.getHeight();

		var view = new Mat4();
		var proj = Mat4.from_ortho(-w/2, w/2, h/2, -h/2, -500, 500);

		var sky_view = view;

		if (camera != null) {
			view = camera.view;
			proj = camera.projection;

			var q = Quat.slerp((camera.tilt), new Quat(0, 0, 0, 1), 0.85);
			sky_view = Mat4.rotate(q) * camera.view;

			var curve = 1.0;
			var threshold = 0.1;
			if (curve > threshold) {
				curve = 1;
			}
			else if (curve > 0) {
				curve = curve / threshold;
			}
			send(shader, "u_clips", new Vec3(camera.near, Utils.max(camera.far*curve, camera.near + 75), 0).unpack());
			send(shader, "u_curvature", camera.far/20);
			send(shader, "u_camera_pos", camera.position.unpack());
			send(shader, "u_camera_dir", camera.direction.unpack());
		}

		// the inverse viewproj is used by the sky shader, and positions screw it up.
		// so we just use the inverse of the view rotation * proj
		var view_rot = sky_view.copy();
		view_rot[14] = 0;
		view_rot[13] = 0;
		view_rot[12] = 0;

		var inv = Mat4.inverse(proj * view_rot);

		var ld = Time.sun_direction;
		send(shader, "u_fog_color", new Vec3(1.0*Time.sun_brightness, 2.0*Time.sun_brightness, 3.0*Time.sun_brightness).unpack());
		send(shader, "u_light_direction", ld.unpack());
		send(shader, "u_light_intensity", Time.sun_brightness);
		send_mtx(shader, "u_view", view);
		send_mtx(shader, "u_projection", proj);
		send_mtx(shader, "u_inv_view_proj", inv);
	}
}
