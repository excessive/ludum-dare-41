package utils;

#if imgui
import math.Vec3;
import math.Quat;
import math.Utils;

import imgui.ImGui;

class Helpers {
	public static function any_value(label, v: Dynamic) {
		ImGui.text(label + ": " + Std.string(v));
	}

	public static function drag_vec3(label, v: Vec3, enabled = true, speed: Float = 0.1, min: Float = -9999, max: Float = 9999) {
		var r = ImGui.drag_float3(label, v[0], v[1], v[2], speed, min, max);
		if (!enabled) {
			return;
		}
		v[0] = r.f1;
		v[1] = r.f2;
		v[2] = r.f3;
	}

	public static function input_vec3(label, v: Vec3, enabled = true) {
		var r = ImGui.input_float3(label, v[0], v[1], v[2]);
		if (!enabled) {
			return;
		}
		v[0] = r.f1;
		v[1] = r.f2;
		v[2] = r.f3;
	}

	public static function input_quat(label, q: Quat, enabled = true) {
		var eul = q.to_euler();
		var result = ImGui.drag_float3(label, Utils.deg(eul[0]), Utils.deg(eul[1]), Utils.deg(eul[2]), 0.5, -180, 180);
		if (!enabled) {
			return;
		}
		eul[0] = Utils.rad(result.f1);
		eul[1] = Utils.rad(result.f2);
		eul[2] = Utils.rad(result.f3);
		var tmp = Quat.from_euler(eul);
		for (i in 0...4) {
			q[i] = tmp[i];
		}
	}
}

#end
