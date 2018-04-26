package collision;

import math.Vec3;

@:publicFields
class CollisionPacket {
	// r3 space
	var r3_position: Vec3 = new Vec3(0.0, 0.0, 0.0);
	var r3_velocity: Vec3 = new Vec3(0.0, 0.0, 0.0);

	// ellipsoid space
	var e_radius:        Vec3 = new Vec3(1.0, 1.0, 1.0);
	var e_position:      Vec3 = new Vec3(0.0, 0.0, 0.0);
	var e_velocity:      Vec3 = new Vec3(0.0, 0.0, 0.0);
	var e_norm_velocity: Vec3 = new Vec3(0.0, 0.0, 0.0);
	var e_base_point:    Vec3 = new Vec3(0.0, 0.0, 0.0);

	// hit information
	var found_collision:  Bool  = false;
	var nearest_distance: Float = 0.0;
	var intersect_point:  Vec3  = new Vec3(0.0, 0.0, 0.0);
	var intersect_time:   Float = 0.0;
	var intersect_normal: Vec3  = new Vec3(0.0, 0.0, 1.0);

	// iteration depth
	var depth:    Int  = 0;
	var grounded: Bool = false;

	inline function new() {}

	static inline function from_entity(position: Vec3, velocity: Vec3, radius: Vec3) {
		var packet = new CollisionPacket();
		packet.r3_position = position;
		packet.r3_velocity = velocity;

		packet.e_radius   = radius;
		packet.e_position = packet.r3_position / packet.e_radius;
		packet.e_velocity = packet.r3_velocity / packet.e_radius;

		return packet;
	}
}
