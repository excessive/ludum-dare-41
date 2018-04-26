package systems;

#if imgui
import imgui.ImGui;
#end
import components.Transform;
import math.Vec3;
import math.Bounds;
import math.Intersect;
import math.Capsule;
import Debug.line;

@:publicFields
class Trigger extends System {
	var player: Null<Entity>;

	override function filter(e: Entity) {
		if (e.player != null) {
			this.player = e;
		}
		return e.trigger != null && e.transform != null;
	}

	static function in_front_of(p: Transform, e: Transform, max_distance: Float, min_angle: Float) {
		var dir = p.orientation * -Vec3.unit_y();

		var ppos = p.position;
		var epos = e.position;
		var p2e = epos - ppos;
		p2e.normalize();

		if (Vec3.dot(p2e, dir) > min_angle) {
			var in_range = Vec3.distance(ppos, epos) <= max_distance;
			var offset = new Vec3(0, 0, 0.001);
			if (in_range) {
				line(ppos + offset, ppos + p2e + offset, 0, 1, 0.5);
			}
			else {
				line(ppos + offset, ppos + p2e + offset, 1, 0, 0.5);
			}
			return in_range;
		}

		return false;
	}

	override function update(entities: Array<Entity>, dt: Float) {
#if imgui
		if (ImGui.get_want_capture_keyboard()) {
			return;
		}
#end

		if (this.player == null) {
			return;
		}

		var p = this.player;
		var ppos = p.transform.position;
		var pcap = new Capsule(p.player.last_position, ppos, p.collidable.radius.length());
		var dir = p.transform.orientation.apply_forward();
		line(ppos, ppos + dir, 1, 1, 0);

		var range = new Vec3(0, 0, 0);
		for (e in entities) {
			var trigger = e.trigger;
			var tpos = e.transform.position;
			var tcap = new Capsule(tpos, tpos, trigger.range);
			var hit = false;
			switch (trigger.type) {
				case Radius:
					hit = Intersect.capsule_capsule(pcap, tcap) != null;
				case Volume:
					for (i in 0...3) {
						range[i] = trigger.range;
					}
					hit = Intersect.point_aabb(ppos, Bounds.from_extents(tpos - range, tpos + range));
				case RadiusInFront:
					hit = in_front_of(p.transform, e.transform, trigger.range, 1-trigger.max_angle);
			}
			if (hit) {
				trigger.cb(e, trigger.inside ? Inside : Entered);
				trigger.inside = true;
			}
			else if (trigger.inside) {
				trigger.cb(e, Left);
				trigger.inside = false;
			}
		}
	}
}
