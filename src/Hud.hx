import ui.Anchor;
import love.graphics.GraphicsModule as Lg;

class Hud {
	static inline function format(fmt: String, args: Array<Dynamic>): String {
		var _real = untyped __lua__("{}");
		for (i in 0...args.length) {
			untyped __lua__("table.insert({0}, {1})", _real, args[i]);
		}
		return untyped __lua__("string.format({0}, unpack({1}))", fmt, _real);
	}

	static var textures = new Map<String, love.graphics.Image>();

	public static function init() {
		// i'm sorry
		textures["ready"] = Lg.newImage("assets/textures/text-ready.png");
		textures["go"]    = Lg.newImage("assets/textures/text-go.png");
		textures["fail"]  = Lg.newImage("assets/textures/text-fail.png");
		textures["goal"]  = Lg.newImage("assets/textures/text-goal.png");
	}

	public static var big_font(default, null): love.graphics.Font;
	public static var small_font(default, null): love.graphics.Font;

	public static function draw() {
		var player = Render.player;
		if (big_font == null) {
			big_font = Lg.newFont("assets/animeace2_reg.ttf", 36);
		}
		if (small_font == null) {
			small_font = Lg.newFont("assets/animeace2_reg.ttf", 24);
		}
		var font = big_font;
		Lg.setFont(font);
		Lg.setColor(1, 0.866667, 0, 1);

		// this code is gonna give me a stroke
		inline function stroke(text: String, x: Float, y: Float, size: Int) {
			var color = Lg.getColor();

			Lg.setColor(0, 0, 0, 1);
			Lg.print(text, x,        y + size);
			Lg.print(text, x + size, y + size);
			Lg.print(text, x + size, y       );
			Lg.print(text, x + size, y - size);
			Lg.print(text, x,        y - size);
			Lg.print(text, x - size, y - size);
			Lg.print(text, x - size, y       );
			Lg.print(text, x - size, y + size);

			Lg.setColor(color.r, color.g, color.b, color.a);
			Lg.print(text, x, y);
		}

		inline function print(w: Float, num: Float, unit: String, x: Float, y: Float) {
			var font = Lg.getFont();
			var num = format("%0.0f", [num]);
			var left = x + w;
			stroke(num, left - font.getWidth(num), y, 2);
			stroke(unit, left, y, 2);
		}

		inline function space(n: Int) {
			return Anchor.bottom - font.getHeight() * n;
		}

		inline function lie_about(speed: Float) {
			return speed * 0.5;
		}

		// speedometer
		var width = font.getWidth("999.9");
		var speed = player.transform.velocity.length();
		// print(width, speed, "m/s", Anchor.left, space(3));
		// print(width, speed / 1000.000 * 60 * 60, "kmph", Anchor.left, space(2));
		print(width, lie_about(speed / 1609.344 * 60 * 60), "mph", Anchor.right - width - font.getWidth("mph"), space(1));

		// pillows
		// var pillows = format("%d Waifus", [Render.player.player.pillows]);
		// if (Stage.total_pillows == 0) {
		// 	pillows = "No Waifus!?";
		// }

		// stroke(pillows, Anchor.right - font.getWidth(pillows), Anchor.bottom - font.getHeight(), 2);

		// timer
		var timer = format("%0.0f", [Stage.time]);
		stroke(timer, Anchor.center_x - font.getWidth(timer), Anchor.top, 2);

		font = small_font;
		Lg.setFont(font);
		timer = format("%02d", [Std.int((Stage.time-Math.floor(Stage.time))*100)]);
		stroke(timer, Anchor.center_x, Anchor.top, 2);
		font = big_font;
		Lg.setFont(font);

		// stage name
		var name = format("%02d - %s", [ Stage.index, Stage.name ]);
		stroke(name, Anchor.left, Anchor.bottom - font.getHeight(), 2);

		// trigger thingies
		Lg.setColor(1, 1, 1, 1);

		if (Stage.state != Stage.StageState.Clear && !Menu.title_mode) {
			var screen = Lg.getDimensions();
			var sx = screen.width  / 1920;
			var sy = screen.height / 1080;

			switch(Stage.state) {
				case Ready:
				Lg.draw(textures["ready"], 0, 0, 0, sx, sy);

				case Go:
				Lg.draw(textures["go"], 0, 0, 0, sx, sy);

				case Fail:
				Lg.draw(textures["fail"], 0, 0, 0, sx, sy);

				case Goal:
				Lg.draw(textures["goal"], 0, 0, 0, sx, sy);

				default:
			}
		}
	}
}
