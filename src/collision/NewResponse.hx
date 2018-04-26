package collision;

import math.Vec3;
import math.Plane;
import math.Utils;
import math.Triangle;

// This implements the improvements to Kasper Fauerby's "Improved Collision
// detection and Response" proposed by Jeff Linahan's "Improving the Numerical
// Robustness of Sphere Swept Collision Detection"
class NewResponse {
	static var VERY_CLOSE_DIST: Float = 0.005;

	static function collide_with_world(packet: CollisionPacket, e_position: Vec3, e_velocity: Vec3, slide_threshold: Float) {
		var first_plane: Plane = new Plane(new Vec3(), new Vec3());
		var dest: Vec3 = e_position + e_velocity;

		// check for collision
		for (i in 0...3) {
			packet.e_norm_velocity = e_velocity.copy();
			packet.e_norm_velocity.normalize();
			packet.e_velocity = e_velocity.copy();
			packet.e_base_point = e_position.copy();
			packet.found_collision = false;
			packet.nearest_distance = 1e20;

			// check for collision
			// NB: scale the octree query by velocity to make sure we still get the
			// triangles we need at high velocities. without this, long falls will
			// jam you into the floor. A bit (25%) of padding is added so I can
			// sleep at night.
			//
			// TODO: can this be cached? max velocity will never increase, so
			// it seems like it'd be safe to query the max size only once, before
			// hitting this function at all.
			var scale = Utils.max(1.5, e_velocity.length()) * 1.25;

			var r3_position = e_position * packet.e_radius;
			var query_radius = packet.e_radius * scale;
			var min = r3_position - query_radius;
			var max = r3_position + query_radius;
			var tris = World.get_triangles(min, max);
			check_collision(packet, tris);

			// no collision
			if (!packet.found_collision) {
				return dest;
			}

			var touch_point = e_position + e_velocity * packet.intersect_time;

			var pn = touch_point - packet.intersect_point;
			pn.normalize();

			var dz = Vec3.dot(pn, Vec3.unit_z());
			if (dz >= 0.25) {
				// Debug.line(new_dest_point * packet.e_radius, new_dest_point * packet.e_radius + new Vec3(0, 0, 1), 0, 0, 1);
				packet.grounded = true;
			}

			var p = new Plane(packet.intersect_point, pn);
			var n = p.normal / packet.e_radius;
			n.normalize();

			var r3_plane = new Plane(p.origin * packet.e_radius, n);
			Debug.plane(r3_plane, 1, 0, 1, 0);

			var dist = e_velocity.length() * packet.intersect_time;
			var short_dist = Utils.max(dist - VERY_CLOSE_DIST, 0.0);

			var nvel = e_velocity.copy();
			nvel.normalize();
			e_position += nvel * short_dist;

			packet.intersect_normal += p.normal;

			if (i == 0) {
				var long_radius = 1.0 + VERY_CLOSE_DIST;
				first_plane = p;

				dest -= first_plane.normal * (first_plane.signed_distance(dest) - long_radius);
				e_velocity = dest - e_position;
			} else if (i == 1) {
				var second_plane = p;
				var crease = Vec3.cross(first_plane.normal, second_plane.normal);
				crease.normalize();

				var dis = Vec3.dot(dest - e_position, crease);
				e_velocity = crease * dis;
				dest = e_position + e_velocity;
			}
		}

		return e_position;
	}

	static function check_collision(packet: CollisionPacket, tris: Array<Triangle>) {
		for (tri in tris) {
			Collision.check_triangle(
				packet,
				tri.v0 / packet.e_radius,
				tri.v1 / packet.e_radius,
				tri.v2 / packet.e_radius
			);
		}
	}

	static function collide_and_slide(packet: CollisionPacket, gravity: Vec3) {
		var player_position = packet.r3_position.copy();

		// convert to e-space
		var e_position      = packet.r3_position / packet.e_radius;
		var e_velocity      = packet.r3_velocity / packet.e_radius;
		var final_position  = new Vec3();
		var slide_threshold = 0.9;

		// do velocity iteration
		packet.depth   = 0;
		final_position = collide_with_world(packet, e_position, e_velocity, slide_threshold);

		// convert velocity to e-space
		e_velocity += gravity / packet.e_radius;

		// do gravity iteration
		packet.depth   = 0;
		final_position = collide_with_world(packet, final_position, e_velocity, slide_threshold);

		// convert back to r3-space
		packet.r3_position = final_position     * packet.e_radius;
		packet.r3_velocity = packet.r3_position - player_position;

		packet.intersect_normal = packet.intersect_normal * packet.e_radius;
		packet.intersect_normal.normalize();
	}

	public static function update(packet: CollisionPacket, gravity: Vec3) {
		collide_and_slide(packet, gravity);
	}
}
