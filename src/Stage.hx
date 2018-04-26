import math.Vec3;
import math.Mat4;
import components.Trigger;

enum StageState {
	Clear;
	Ready;
	Go;
	Fail;
	Goal;
}

typedef RawStageData = {
	matrices_as_column_major: Bool,
	objects: Array<{
		name: String,
		position: Array<Float>,
		size: Array<Float>,
		transform: Array<Float>,
		transform_without_scale: Array<Float>,
		type: String
	}>,
	paths: Array<{
		name: String,
		points: Array<{
			handle_left: Array<Float>,
			handle_right: Array<Float>,
			position: Array<Float>
		}>,
		type: String
	}>,
	trigger_areas: Array<{
		name: String,
		position: Array<Float>,
		size: Array<Float>,
		transform: Array<Float>,
		transform_without_scale: Array<Float>,
		type: String
	}>
}

class Stage {
	static function fix_name(name: String): String {
		// if an object is for some reason just named ".", whatever
		var dot = name.indexOf(".");

		if (dot > 0) {
			return name.substr(0, dot);
		}

		return name;
	}

	public static var name(default, null): String = "Untitled";
	public static var index(default, null): Int = 0;
	public static var spawn_point(default, null) = new Vec3(0, 0, 0);
	public static var kill_z: Float = -10.0;
	public static var total_pillows(default, null): Int = 0;
	public static var time(default, null): Float = 0.0;
	public static var stop_time: Bool = false;
	public static var time_elapsed(get, never): Float;
	public static var state = Clear;
	static var time_limit: Float = 45.0;

	public static function update(dt: Float) {
		if (GameInput.locked || stop_time) {
			return;
		}

		time = Math.max(0, time - dt);

		if (time == 0) {
			Signal.emit("fail");
		}
	}

	static inline function get_time_elapsed() {
		return time_limit - time;
	}

	public static function load(filename: String, _name: String, _index: Int) {
		name  = _name;
		index = _index;

		var root = new SceneNode();
		root.transform.is_static = true;
		root.transform.update();

		total_pillows = 0;
		time = time_limit;
		stop_time = false;

		var json = backend.Fs.read(filename).toString();
		if (json != null) {
			var data: RawStageData = haxe.Json.parse(json);

			for (object in data.objects) {
				var node = new SceneNode();
				node.name = fix_name(object.name);
				node.transform.position = new Vec3(
					object.position[0],
					object.position[1],
					object.position[2]
				);
				node.transform.scale = new Vec3(
					object.size[0],
					object.size[1],
					object.size[2]
				);
				node.transform.is_static = true;
				node.transform.update();

				node.material = {
					color: new Vec3(0, 1, 1),
					emission: 0.0,
					metalness: 0.0,
					roughness: 1.0,
					vampire: true
				};

				switch (node.name) {
					case "spawn":  spawn_point = node.transform.position.copy();
					case "kill_z": kill_z      = node.transform.position.z;
					default: break;
				}

				root.children.push(node);
			}

			var models = {
				goal:           iqm.Iqm.load("assets/models/goal.iqm"),
				goal_collision: iqm.Iqm.load("assets/models/goal_collision.iqm", true),
				pillow:         iqm.Iqm.load("assets/models/pillow.iqm")
			};

			for (trigger in data.trigger_areas) {
				var node = new SceneNode();
				node.name = fix_name(trigger.name);

				node.transform.position = new Vec3(
					trigger.position[0],
					trigger.position[1],
					trigger.position[2]
				);

				var type: TriggerType = switch (trigger.type) {
					case "CUBE":       Volume;
					case "SPHERE":     Radius;
					case "PLANE_AXES": Radius;
					default:           Radius;
				}

				switch(node.name) {
					case "goal":
						node.transform.is_static = true;
						node.transform.update();
						node.transform.matrix = new Mat4(trigger.transform_without_scale);
						node.transform.normal_matrix = Mat4.inverse(node.transform.matrix);
						node.transform.normal_matrix.transpose();

						World.add_triangles(World.convert(models.goal_collision.triangles), node.transform.matrix);

						node.drawable = [ models.goal.mesh ];
						node.trigger  = new Trigger(
							function(e: Entity, ts: TriggerState) {
								var complete = Render.player.player.pillows == total_pillows;
								if (ts == Entered) {
									Signal.emit("goal", {
										entity: e,
										time: time_elapsed,
										pillows: Render.player.player.pillows,
										complete: complete
									});
								}
							},
							type,
							node.transform.scale.length() / 6
						);

					case "pillow":
						node.drawable            = [ models.pillow.mesh ];
						node.trigger             = new Trigger(
							function(e: Entity, ts: TriggerState) {
								if (ts == Inside) {
									Signal.emit("pillow", node);
								}
							},
							type,
							node.transform.scale.length() / 4
						);
						node.item = Pillow;
						total_pillows += 1;

					default:
				}

				root.children.push(node);
			}
		}

		return root;
	}
}
