import love.graphics.GraphicsModule as Lg;

import backend.Window as PlatformWindow;
import backend.Profiler;

#if imgui
import imgui.ImGui as Ui;
#end

import math.Vec3;
import math.Mat4;
import math.Quat;
import render.*;

class Render {
	public static var camera = new Camera(new Vec3());
	public static var player: SceneNode;

	public static function init() {
		Debug.init();
		Shader.init();
	}

	static var gbuffer: GBuffer;

	static var lowres = false;
	static var highres = false;

	public static function reset(w: Float, h: Float) {
		var lag = 1.0;
		lag *= lowres? 0.5 : 1.0;
		lag *= highres? 2.0 : 1.0;
		if (gbuffer != null) {
			for (c in gbuffer.layers) {
				c.release();
			}
			gbuffer.depth.release();
			gbuffer.out1.release();
			gbuffer.out2.release();
		}
		w *= lag;
		h *= lag;
		gbuffer = {
			layers: [
				// albedo (rgb) + roughness (a)
				untyped __lua__("love.graphics.newCanvas( {0}, {1}, { format = 'rgba8' } )", w, h),
				// normal (rg) + distance (b) + unused (a)
				untyped __lua__("love.graphics.newCanvas( {0}, {1}, { format = 'rgb10a2' } )", w, h),
			],
			// depth
			depth: untyped __lua__("love.graphics.newCanvas( {0}, {1}, { format = 'depth24' } )", w, h),
			// final combined rg11b10f buffer. might need to increase to rgba16f?
			out1: untyped __lua__("love.graphics.newCanvas( {0}, {1}, { mipmaps = 'manual', format = 'rg11b10f' } )", w, h),
			// final tonemapped buffer we apply AA to
			out2: untyped __lua__("love.graphics.newCanvas( {0}, {1}, { format = 'rgb10a2' } )", w, h)
		};

		if (lowres && false) {
			gbuffer.out1.setFilter(Linear, Nearest);
			gbuffer.out2.setFilter(Linear, Nearest);
		}
	}

	static var force_forward = true;
	static var debug_draw = false;
	public static var show_profiler = false;

	static function render_game(width: Float, height: Float, state: Array<Entity>, alpha: Float) {
		var vp: Viewport = { x: 0, y: 0, w: width, h: height };
		camera.update(vp.w, vp.h, alpha);

		Lg.setColor(1, 1, 1, 1);

		Profiler.push_block("Prepare");
#if imgui
		if (Ui.checkbox("FXAA", PostPass.use_fxaa)) {
			PostPass.use_fxaa = !PostPass.use_fxaa;
		}
		if (Ui.checkbox("More Ghetto", lowres)) {
			highres = false;
			lowres = !lowres;
			reset(width, height);
		}
		if (Ui.checkbox("Less Ghetto", highres)) {
			lowres = false;
			highres = !highres;
			reset(width, height);
		}
		if (Ui.checkbox("Debug", debug_draw)) {
			debug_draw = !debug_draw;
		}
		var ret = Ui.slider_float("Gravity", systems.PlayerController.gravity_strength, 0.5, 1.5);
		systems.PlayerController.gravity_strength = ret.f1;

		ret = Ui.slider_float("Friction", systems.PlayerController.friction, 0.005, 0.025);
		systems.PlayerController.friction = ret.f1;
#end

		var forward: Array<DrawCommand> = [];

		// interpolate dynamic objects and sort objects into the appropriate pass
		var white = new Vec3(1, 1, 1);
		for (e in state) {
			var color = e.material != null ? e.material.color : white;
			Lg.setColor(color.x, color.y, color.z, 1);
			var use_triplanar = false;
			if (e.material != null && e.material.triplanar != null) {
				use_triplanar = e.material.triplanar;
			}
			if (e.drawable != null) {
				var mtx = e.transform.matrix;
				var inv = e.transform.normal_matrix;

				if (!e.transform.is_static) {
					var a = e.last_tx.position;
					var b = e.transform.position;
					var pos = Vec3.lerp(a, b, alpha) + e.transform.offset;
					var rot = Quat.lerp(e.last_tx.orientation, e.transform.orientation, alpha);
					var scale = Vec3.lerp(e.last_tx.scale, e.transform.scale, alpha);
					mtx = Mat4.from_srt(pos, rot, scale);
					// mtx = Mat4.translate(pos) * Mat4.rotate(rot);

					inv = Mat4.inverse(mtx);
					inv.transpose();
				}

				for (submesh in e.drawable) {
					var cmd: DrawCommand = {
						xform_mtx: mtx,
						normal_mtx: inv,
						mesh: submesh,
						triplanar: use_triplanar,
						bones: null
					};
					forward.push(cmd);
				}
			}
		}

		Lg.setColor(1, 1, 1, 1);

		Profiler.pop_block();

		if (force_forward) {
			Profiler.push_block("Render wait");
			Lg.setCanvas(untyped __lua__("{ {0}, depthstencil = {1} }", gbuffer.out1, gbuffer.depth));
			Lg.clear(untyped __lua__("{ love.graphics.getBackgroundColor() }"), cast false, cast true);
			Profiler.pop_block();
		}
		ForwardPass.render(gbuffer.out1, gbuffer.depth, forward);
		SkyPass.render(gbuffer.out1, gbuffer.depth);

		if (debug_draw) {
			DebugPass.render(gbuffer.out1, gbuffer.depth);
		}
		else {
			Debug.draw(true);
			Debug.clear_capsules();
		}
		PostPass.render(gbuffer, vp);

#if imgui
		if (Ui.begin("Render Stats")) {
			Ui.text('batches: ${forward.length}');
			Ui.same_line();
			Ui.text('(deferred: n/a, forward: ${forward.length})');
			var stats = Lg.getStats();
			var diff = stats.drawcalls - (forward.length);
			Ui.text('misc draws: $diff');
			Ui.text('auto-batched drawcalls: ${stats.drawcallsbatched}');
			Ui.text('total drawcalls: ${stats.drawcalls}');
			Ui.text('canvas switches: ${stats.canvasswitches}');
			Ui.text('texture memory (MiB): ${Std.int(stats.texturememory/1024/1024)}');
		}
		Ui.end();
#end

		Lg.setColor(1, 1, 1, 1);
		Lg.setCanvas();
		Lg.setWireframe(false);
		Lg.setMeshCullMode(None);
		Lg.setDepthMode();
		Lg.setBlendMode(Alpha);
		Lg.setShader();

		// 2D stuff
		Hud.draw();
		Menu.draw();

		// reset
		Lg.setColor(1, 1, 1, 1);
	}

	public static function frame(window: PlatformWindow, state: Array<Entity>, alpha: Float) {
		var size = window.get_size();
		if (gbuffer == null) {
			reset(size.width, size.height);
		}
		render_game(size.width, size.height, state, alpha);
	}
}
