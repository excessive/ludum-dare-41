package systems;

import collision.CollisionPacket;
import collision.NewResponse as Response;

import math.Vec2;
import math.Vec3;
import math.Quat;
import math.Utils;

class PlayerController extends System {
	override function filter(e: Entity) {
		return e.player != null && e.physics != null;
	}

	public static var gravity_strength = 0.70;
	public static var friction         = 0.00825;

	function get_thingy(move: Vec3, tetsumusu: Quat) {
		var ml = move.length();

		// figure out movement relative to camera, nudged to handle no inputs
		var angle: Float = new Vec2(move.x, move.y + 0.0001).angle_to() + Math.PI / 2;
		var move_orientation: Quat = tetsumusu * Quat.from_angle_axis(angle, Vec3.up());
		move_orientation.x = 0;
		move_orientation.y = 0;
		move_orientation.normalize();

		// accelerate
		var move_right = move_orientation * Vec3.right();
		return Quat.from_angle_axis(Math.pow(ml, 3) * -gravity_strength, move_right);
	}

	override function process(e: Entity, dt: Float) {
		Menu.update(dt);

		if (GameInput.locked) {
			return;
		}

		if (GameInput.pressed(MenuToggle)) {
			GameInput.lock();
			return;
		}

		if (GameInput.pressed(Respawn) && !Stage.stop_time) {
			Signal.emit("cancel-respawn");
			Signal.emit("respawn", e);
			return;
		}

		// record position so we can do capsule collisions for triggers,
		// so we can't miss a goal by going fast.
		e.player.last_position = e.transform.position.copy();

		var gravity_orientation = new Quat(0, 0, 0, 1);
		var camera_tilt         = new Quat(0, 0, 0, 1);

		var xform = e.transform;
		var cam   = Render.camera;
		var stick = GameInput.move_xy();
		var move  = new Vec3(stick.x, stick.y, 0);

		// Adjust -y input
		if (move.y < 0) {
			var vel = xform.velocity.length();

			// velocity is camera backward
			var limit = 3;
			if (vel < limit && Vec3.dot(move, new Vec3(0, -1, 0)) > 0.85) {
				var m2 = move.copy();
				var mix = vel / limit;
				move.y *= move.x;
				m2 = Vec3.lerp(move, m2, mix);
				move.x = m2.x;
				move.y = m2.y;
				move.trim(1.0);
			}
		}

		var ml = move.length();

		if (ml > 0) {
			if (move.trim(1.0)) {
				ml = 1;
			}
			move = -move;
			camera_tilt = get_thingy(move, cam.orientation);

			var d = xform.velocity.copy();
			d.normalize();
			var angle: Float = new Vec2(d.x, d.y + 0.0001).angle_to() + Math.PI / 2;
			var fast = get_thingy(move, Quat.from_angle_axis(angle, Vec3.up()));
			var slow = get_thingy(move, cam.orientation);
			var sel = Utils.map(xform.velocity.length(), 0, 20, 0, 1);
			gravity_orientation = Quat.slerp(slow, fast, Utils.min(sel, 1));
		}

		// slow down
		// MAGIC NUMBER IT JUST WORKS
		var apply_friction = 0.0;
		if (e.physics.on_ground) {
			apply_friction = friction;
		}
		if (Stage.stop_time) {
			apply_friction = 0.05;
		}
		xform.velocity *= (1.0 - apply_friction) * 0.5;

		// handle collisions
		var gravity       = gravity_orientation * Vec3.up() * -gravity_strength;
		var radius        = e.collidable.radius;
		var visual_offset = new Vec3(0, 0, radius.z);
		var packet        = CollisionPacket.from_entity(
			xform.position + visual_offset,
			xform.velocity * dt,
			radius
		);

		Response.update(packet, gravity * dt);

		var old_speed    = xform.velocity.length();
		var old_direction = xform.velocity.copy();
		old_direction.normalize();

		xform.position = packet.r3_position - visual_offset;
		xform.velocity = packet.r3_velocity / dt;

		var new_speed    = xform.velocity.length();
		var new_direction = xform.velocity.copy();
		new_direction.normalize();

		// hacky bonk
		var d = Vec3.dot(old_direction, new_direction);
		if (old_speed > 9 && d > 0 && d < 0.97) {
			// xform.velocity = new_direction * old_speed;
			xform.velocity = Vec3.reflect(old_direction, Vec3.cross(new_direction, Vec3.up() + new Vec3(0.0, 0.001, 0.0))) * new_speed;
			// xform.velocity = Vec3.reflect(old_direction, packet.intersect_normal) * new_speed;
			Sfx.bonk.play();
		}

		e.physics.on_ground = packet.grounded;
		if (e.physics.on_ground) {
			var forward = xform.velocity.copy();
			forward.normalize();

			var right     = Vec3.cross(forward, gravity_orientation * Vec3.up());
			e.player.spin = Quat.from_angle_axis(xform.velocity.length() * -dt, right);
		}
		xform.orientation = e.player.spin * xform.orientation;
		xform.orientation.normalize();

		// reset/kill-z
		if (xform.position.z < Stage.kill_z && !Stage.stop_time) {
			Signal.emit("fail");
		}

		cam.target = xform.position + xform.offset;

		var bias  = cam.orientation.apply_forward() * -0.001;
		var speed = xform.velocity.length();

		e.player.lag_position = Vec3.lerp(e.player.lag_position, cam.target, speed*0.0175*0.5) + bias;
		e.player.lag_tilt     = Quat.slerp(e.player.lag_tilt, camera_tilt, 1/8);

		cam.position = e.player.lag_position;
		cam.tilt     = e.player.lag_tilt;

		if (speed > 0) {
			var d = cam.target - cam.position;
			d.normalize();

			var angle: Float = new Vec2(d.x, d.y + 0.0001).angle_to() + Math.PI / 2;
			cam.orientation = Quat.from_angle_axis(angle, gravity_orientation * Vec3.up());
			cam.direction = cam.orientation.apply_forward();
		}

		if (e.physics.on_ground) {
			Sfx.wub_for_speed(speed);
		}
	}
}
