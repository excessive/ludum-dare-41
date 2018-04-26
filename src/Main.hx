import backend.BaseGame;
import backend.GameLoop;
import backend.Input;
import backend.Profiler;
import components.*;
import systems.*;
import math.Vec3;
import love.audio.AudioModule as La;

typedef LevelEntry = {
	map: String,
	name: String
}

class Main extends BaseGame {
	static function load_levels(): Array<LevelEntry> {
		var data = backend.Fs.read("assets/levels.json");
		var ret: Array<LevelEntry> = haxe.Json.parse(data.toString());
		return ret;
	}

	public static var game_title = "LD41 - Clunky Ball";
	public static var scene: Scene;
	public static var levels: Array<LevelEntry>;
	public static var current_level: Int = 0;
	public static var stage_data: Array<{
		stage:   Int,
		time:    Float,
		pillows: Float
	}> = [];

	var systems:       Array<System>;
	var lag:           Float = 0.0;
	var timestep:      Float = 1 / 60;
	var current_state: Array<Entity>;

	public static function new_scene() {
		scene = new Scene();

		var player        = new SceneNode();
		player.collidable = new Collidable();
		player.physics    = new Physics();
		player.player     = new Player();
		player.name       = "Korbo";
		player.drawable   = [
			iqm.Iqm.load("assets/models/ball.iqm").mesh
		];
		Render.player = player;

		var map = World.init(levels[current_level], current_level+1);
		scene.add(map);

		var ball_size = 0.5;
		player.collidable.radius    = new Vec3(1, 1, 1) * ball_size;
		player.transform.position   = Stage.spawn_point.copy();
		player.player.last_position = player.transform.position.copy();
		player.player.lag_position  = player.transform.position.copy();
		player.transform.offset.z   = ball_size;
		player.transform.scale      = new Vec3(1, 1, 1) * ball_size;
		scene.add(player);

		var cam = Render.camera;
		cam.orientation.x = 0;
		cam.orientation.y = 0;
		cam.orientation.z = 0;
		cam.orientation.w = 1;
		cam.direction     = cam.orientation.apply_forward();
		cam.position      = player.transform.position.copy();
	}

	static var quiet = true;

	override function load(args) {
#if imgui
		Input.set_relative(true);
#end

		levels = load_levels();

		var duck = 0.25;
		var bgm = La.newSource("assets/bgm/hype.mp3", Stream);
		bgm.setLooping(true);
		bgm.setVolume(0.3 * duck);
		bgm.play();

		Signal.register("quiet", function(_) {
			if (quiet) {
				return;
			}
			bgm.setVolume(bgm.getVolume() * duck);
			quiet = true;
		});

		Signal.register("loud", function(_) {
			if (!quiet) {
				return;
			}
			bgm.setVolume(bgm.getVolume() * (1/duck));
			quiet = false;
		});

		GameInput.init();
		Sfx.init();
		Time.init();
		Render.init();
		Hud.init();
		Menu.update(0);

		systems = [
			new ItemEffect(),
			new PlayerController(),
			new Trigger()
		];

		var respawn_wait = null;

		Signal.register("surrender", function(_) {
			current_level = 0;
			new_scene();
		});

		Signal.register("cancel-respawn", function(_) {
			Signal.cancel(respawn_wait);
			respawn_wait = null;
		});

		Signal.register("respawn", function(e: Entity) {
			new_scene();
			Sfx.respawn.play();
			Signal.emit("hud-ready");
		});

		Signal.register("goal", function(stats: { entity: Entity, time: Float, pillows: Int, complete: Bool }) {
			// Record stage time
			stage_data.push({
				stage:   current_level,
				time:    stats.time,
				pillows: stats.pillows
			});

			current_level += 1;
			current_level %= levels.length;

			Signal.emit("hud-goal");

			Stage.kill_z -= 10000;
			Stage.stop_time = true;

			Signal.after(1.5, function() {

				// Start game over
				if (current_level == 0) {
					// Record data in leaderboard
					Menu.leader_lock();
					Stage.state = Stage.StageState.Clear;
				} else {
					Signal.emit("hud-ready");
				}

				new_scene();
				Sfx.spawn.play();
			});
		});

		Signal.register("pillow", function(node: SceneNode) {
			Render.player.player.pillows += 1;
			scene.remove(node);
		});

		Signal.register("fail", function(_) {
			Sfx.timeout.play();
			Signal.emit("hud-fail");

			if (Stage.time == 0) {
				Menu.fail_lock();
			} else {
				respawn_wait = Signal.after(2, function() {
					Signal.emit("respawn");
				});
			}
		});

		Signal.register("hud-ready", function(_) {
			Stage.state = Stage.StageState.Ready;
			Stage.stop_time = true;

			Signal.after(1, function() {
				Signal.emit("hud-go");
			});
		});

		Signal.register("hud-go", function(_) {
			Stage.state = Stage.StageState.Go;
			Stage.stop_time = false;

			Signal.after(1, function() {
				Stage.state = Stage.StageState.Clear;
			});
		});

		Signal.register("hud-fail", function(_) {
			Stage.state = Stage.StageState.Fail;
			Stage.stop_time = true;
		});

		Signal.register("hud-goal", function(_) {
			Stage.state = Stage.StageState.Goal;
			Stage.stop_time = true;
		});

		Menu.title_lock();

		new_scene();

		// force a tick on the first frame if we're using fixed timestep.
		// this prevents init bugs
		if (timestep > 0) {
			tick(timestep);
		}
	}

	static var frame_start_cbs = new List<Float->Bool>();
	public static inline function on_tick(cb: Float->Bool) {
		frame_start_cbs.push(cb);
	}

	public static var current_entity: Entity;

	function tick(dt: Float) {
		Profiler.push_block("Tick");
		GameInput.update(dt);
		Time.update(dt);
		Stage.update(dt);
		Signal.update(dt);

#if imgui
		GameInput.bind(Debug_F3, function() {
			levels = load_levels();
			current_level -= 1;
			if (current_level < 0) {
				current_level = levels.length-1;
			}
			new_scene();
			Sfx.spawn.play();
			return true;
		});

		GameInput.bind(Debug_F4, function() {
			levels = load_levels();
			current_level += 1;
			current_level %= levels.length;
			new_scene();
			Sfx.spawn.play();
			return true;
		});
#end

		var cam = Render.camera;
		cam.last_position = cam.position;
		cam.last_target   = cam.target;
		cam.last_tilt     = cam.tilt;

		var entities = scene.get_entities();
		Profiler.push_block("Scripts");
		for (e in entities) {
			if (!e.transform.is_static) {
				e.last_tx.position    = e.transform.position.copy();
				e.last_tx.orientation = e.transform.orientation.copy();
				e.last_tx.scale       = e.transform.scale.copy();
				e.last_tx.velocity    = e.transform.velocity.copy();
			}
		}

		for (cb in frame_start_cbs) {
			if (!cb(dt)) {
				frame_start_cbs.remove(cb);
			}
		}
		Profiler.pop_block();

		for (system in systems) {
			Profiler.push_block(system.PROFILE_NAME, system.PROFILE_COLOR);
			var relevant = [];
			for (entity in entities) {
				if (system.filter(entity)) {
					relevant.push(entity);
					system.process(entity, dt);
				}
			}
			system.update(relevant, dt);
			Profiler.pop_block();
		}

		Profiler.pop_block();
	}

	var frame_graph: Array<Float> = [ for (i in 0...250) 0.0 ];

	override function update(window, dt: Float) {
		ui.Anchor.update(window);

#if !imgui
		if (love.mouse.MouseModule.isVisible()) {
			love.mouse.MouseModule.setVisible(false);
		}
#end

		frame_graph.push(dt);
		while (frame_graph.length > 250) {
			frame_graph.shift();
		}

#if imgui
		var region = imgui.ImGui.get_content_region_max();
		imgui.ImGui.plot_lines("", frame_graph, 0, null, 0, 1/30, region[0], 100);
#end

		if (timestep < 0) {
			tick(dt);
			current_state = scene.get_entities();
			return;
		}

		lag += dt;

		while (lag >= timestep) {
			lag -= timestep;
			if (lag >= timestep) {
				Debug.draw(true);
				Debug.clear_capsules();
			}
			tick(timestep);
		}

		current_state = scene.get_entities();
	}

	override function keypressed(key: String, scan: String, isrepeat: Bool) {
		if (!isrepeat) {
			GameInput.keypressed(scan);
		}

#if imgui
		if (key == "escape") {
			Input.set_relative(!Input.get_relative());
		}
#end
	}

	override function keyreleased(key: String, scan: String) {
		GameInput.keyreleased(scan);
	}

	override function resize(w, h) {
		Render.reset(w, h);
	}

	override function draw(window) {
		var alpha = lag / timestep;
		if (timestep < 0) {
			alpha = 1;
		}
		Profiler.push_block("Cull");
		var visible = scene.get_visible_entities();
		Profiler.pop_block();
		Profiler.push_block("Render");
		Render.frame(window, visible, alpha);
		Profiler.pop_block();
	}

	static function main() {
		return GameLoop.run(new Splash());
	}
}
