package render;

import love.graphics.GraphicsModule as Lg;
import math.Vec3;

import backend.Profiler;

class PostPass {
	public static var r: Float = 7;
	public static var g: Float = 14;
	public static var b: Float = 16;
	public static var exposure: Float = 0.75;
	public static var vignette: Float = 0.35;

	public static var use_fxaa = true;

	public static function render(gbuffer: GBuffer, vp: Viewport) {
		Profiler.marker("Post");

		var rw = vp.w / gbuffer.out1.getWidth();
		var rh = vp.h / gbuffer.out1.getHeight();
		var shader = Shader.get("post");
		Lg.setShader(shader);
		if (use_fxaa) {
			Lg.setCanvas(gbuffer.out2); // ping
		}
		else {
			Lg.setCanvas();
		}
		Lg.setBlendMode(Replace, Premultiplied);
		Lg.setDepthMode();
		Helpers.send(shader, "u_white_point", new Vec3(r, g, b).unpack());
		Helpers.send(shader, "u_exposure", exposure);
		Helpers.send(shader, "u_vignette", vignette);
		Lg.setColor(1.0, 1.0, 1.0, 1.0);
		gbuffer.out1.generateMipmaps();
		if (use_fxaa) {
			Lg.draw(gbuffer.out1);

			var shader = Shader.get("fxaa");
			Lg.setShader(shader);
			Lg.setCanvas(gbuffer.out1); // pong
			Lg.draw(gbuffer.out2);
		}
		else {
			Lg.draw(gbuffer.out1, vp.x, vp.y, 0, rw, rh);
		}

		Lg.setCanvas();
		Lg.setShader();
		if (use_fxaa) {
			gbuffer.out1.generateMipmaps();
			Lg.draw(gbuffer.out1, vp.x, vp.y, 0, rw, rh);
		}

		Lg.setBlendMode(Alpha);
	}
}
