package render;

import love.graphics.GraphicsModule as Lg;
import love.graphics.Canvas;

class SkyPass {
	public static function render(shaded: Canvas, depth: Canvas) {
		var shader = Shader.get("sky");
		Lg.setShader(shader);
		Lg.setCanvas(untyped __lua__("{ {0}, depthstencil = {1} }", shaded, depth));
		Helpers.send_uniforms(Render.camera, shader);
		Lg.setDepthMode(Equal, false);
		Lg.rectangle(Fill, -1, -1, 2, 2);
	}
}
