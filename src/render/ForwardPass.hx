package render;

import love.graphics.Canvas;
import love.graphics.GraphicsModule as Lg;
import backend.Profiler;

class ForwardPass {
	static var tripla_tex: love.graphics.Image;

	public static function render(shaded: Canvas, depth: Canvas, draws: Array<DrawCommand>) {
		if (draws.length == 0) {
			return;
		}

		if (tripla_tex == null) {
			var flags: lua.Table<String, Dynamic> = untyped __lua__("{ mipmaps = true }");
			tripla_tex = Lg.newImage("assets/textures/terrain.png", flags);
			tripla_tex.setFilter(Linear, Linear, 16);
			tripla_tex.setWrap(Repeat, Repeat);
		}

		Profiler.push_block("Forward");

		Lg.setCanvas(untyped __lua__("{ {0}, depthstencil = {1} }", shaded, depth));

		var camera = Render.camera;
		var tripla = Shader.get("terrain");
		Lg.setShader(tripla);
		Helpers.send_uniforms(camera, tripla);

		var shader = Shader.get("basic");
		Lg.setShader(shader);
		Helpers.send_uniforms(camera, shader);

		Lg.setFrontFaceWinding(Cw);
		Lg.setDepthMode(Less, true);
		Lg.setMeshCullMode(Back);

		for (d in draws) {
			var s = shader;
			if (d.triplanar) {
				d.mesh.setTexture(tripla_tex);
				s = tripla;
			}
			else {
				d.mesh.setTexture(null);
				s = shader;
			}
			Lg.setShader(s);
			Helpers.send_mtx(s, "u_model", d.xform_mtx);
			Helpers.send_mtx(s, "u_normal_mtx", d.normal_mtx);
			Helpers.send(s, "u_rigged", 0);
			Lg.draw(d.mesh);
		}

		Lg.setDepthMode();
		Lg.setMeshCullMode(None);

		Profiler.pop_block();
	}

}
