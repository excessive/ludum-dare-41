package systems;

import math.Quat;
import math.Vec3;

class ItemEffect extends System {
	override function filter(e: Entity) {
		return e.item != null;
	}

	function pillow_fx(e: Entity, dt: Float) {
		var height = 0.25;
		var spin = Quat.from_angle_axis(-Math.PI * 2 * dt * 0.25, Vec3.up());
		e.transform.orientation = spin * e.transform.orientation;
		e.transform.offset.z    = height - Math.sin(Stage.time_elapsed * 2) * height;
	}

	override function process(e: Entity, dt: Float) {
		if (GameInput.locked) {
			return;
		}

		switch (e.item) {
			case Pillow: pillow_fx(e, dt);
			default:
		}
	}
}
