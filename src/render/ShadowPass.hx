package render;

import love.graphics.Canvas;
import love.graphics.GraphicsModule as Lg;
import backend.Profiler;

class ShadowPass {
	public static function render(shaded: Canvas, depth: Canvas, draws: Array<DrawCommand>) {
		if (draws.length == 0) {
			return;
		}

		Profiler.push_block("Shadow");

		Lg.setCanvas(untyped __lua__("{ {0}, depthstencil = {1} }", shaded, depth));

		var shader = Shader.get("shadow");
		var camera = Render.camera;
		Lg.setShader(shader);
		Helpers.send_uniforms(camera, shader);

		Lg.setFrontFaceWinding(Cw);
		Lg.setDepthMode(Less, true);
		Lg.setMeshCullMode(Back);

		for (d in draws) {
			Helpers.send_mtx(shader, "u_model", d.xform_mtx);
			Helpers.send_mtx(shader, "u_normal_mtx", d.normal_mtx);
			Helpers.send(shader, "u_rigged", 0);
			Lg.draw(d.mesh);
		}

		Lg.setDepthMode();
		Lg.setMeshCullMode(None);

		Profiler.pop_block();
	}

}
