package backend.love;

import love.math.MathModule as Lm;
import love.timer.TimerModule as Lt;
import love.graphics.GraphicsModule as Lg;
import love.audio.AudioModule as La;
import love.Love;
import love.event.EventModule as Event;
import love.keyboard.KeyboardModule as Keyboard;
import love.mouse.MouseModule as Mouse;

import backend.Window;
import backend.Profiler.SegmentColor;

#if imgui
import imgui.Integration;
import imgui.ImGui;
#end

class GameLoop {
	static var window: Window;
	static var _game: BaseGame;
	static var _reload: BaseGame;

	static function load(args: Array<String>) {
		_game.load(args);
	}

	static function update(dt: Float) {
		_game.update(window, dt);
	}

	static function draw() {
		_game.draw(window);
	}

	static function mousepressed(x: Float, y: Float, button: Float, istouch: Bool) {
#if imgui
		if (!Input.get_relative()) {
			Integration.mousepressed(button);
		}
#end

		_game.mousepressed(x, y, Std.int(button));
	}

	static function mousereleased(x: Float, y: Float, button: Float, istouch: Bool) {
#if imgui
		if (!Input.get_relative()) {
			Integration.mousereleased(button);
		}
#end

		_game.mousereleased(x, y, Std.int(button));
	}

	static function mousemoved(x: Float, y: Float, dx: Float, dy: Float, istouch: Bool) {
		Input.mx += dx;
		Input.my += dy;

#if imgui
		if (!Input.get_relative()) {
			Integration.mousemoved(x, y);
		}
#end

		_game.mousemoved(x, y, dx, dy);
	}

	static function wheelmoved(x: Float, y: Float) {
#if imgui
		if (!Input.get_relative()) {
			Integration.wheelmoved(y);
		}
#end

		_game.wheelmoved(x, y);
	}

	static function textinput(str: String) {
		_game.textinput(str);
	}

	static function keypressed(key: String, scan: String, isrepeat: Bool) {
		if (key == "escape" && Keyboard.isDown("lshift", "rshift")) {
			Event.quit();
		}

#if imgui
		if (!Input.get_relative() || key == "escape") {
			Integration.keypressed(key);
		}
#end

		_game.keypressed(key, scan, isrepeat);
	}

	static function keyreleased(key: String, scan: String) {
#if imgui
		if (!Input.get_relative()) {
			Integration.keyreleased(key);
		}
#end

		_game.keyreleased(key, scan);
	}

	static function resize(w: Float, h: Float) {
		_game.resize(w, h);
	}

	public static var was_grabbed = false;
	static function focus(focused: Bool) {
		Input.get_mouse_moved(true);
		Mouse.setRelativeMode(focused && was_grabbed);
	}

	static function quit(): Bool {
		if (!_game.quit()) {
#if imgui
			Integration.shutdown();
#end
			return false;
		}
		return true;
	}

	static function real_run() {
		window = new Window();
		window.open(1920, 1080);

#if imgui
		// var scale = love.window.WindowModule.getDPIScale();

		// ImGui.set_global_font("assets/fonts/Inconsolata-Regular.ttf", 16*scale, 0, 0, 2, 2);
		// Integration.set_global_font("assets/fonts/NotoSans-Regular.ttf", 16*scale, 0, 0, 2, 2);
		ImGui.push_color("Text", 1.00, 1.00, 1.00, 1.00);
		ImGui.push_color("WindowBg", 0.07, 0.07, 0.08, 0.98);
		ImGui.push_color("PopupBg", 0.07, 0.07, 0.08, 0.98);
		ImGui.push_color("CheckMark", 0.15, 1.0, 0.4, 0.91);
		ImGui.push_color("Border", 0.70, 0.70, 0.70, 0.20);
		ImGui.push_color("FrameBg", 0.80, 0.80, 0.80, 0.12);
		ImGui.push_color("FrameBgHovered", 0.04, 0.50, 0.78, 1.00);
		ImGui.push_color("FrameBgActive", 0.15, 0.52, 0.43, 1.00);
		ImGui.push_color("TitleBg", 0.15, 0.52, 0.43, 0.76);
		ImGui.push_color("TitleBgCollapsed", 0.11, 0.22, 0.23, 0.50);
		ImGui.push_color("TitleBgActive", 0.15, 0.52, 0.43, 1.00);
		ImGui.push_color("MenuBarBg", 0.07, 0.07, 0.11, 0.76);
		ImGui.push_color("ScrollbarBg", 0.26, 0.29, 0.33, 1.00);
		ImGui.push_color("ScrollbarGrab", 0.40, 0.43, 0.47, 0.76);
		ImGui.push_color("ScrollbarGrabHovered", 0.28, 0.81, 0.68, 0.76);
		ImGui.push_color("ScrollbarGrabActive", 0.96, 0.66, 0.06, 1.00);
		ImGui.push_color("SliderGrab", 0.28, 0.81, 0.68, 0.47);
		ImGui.push_color("SliderGrabActive", 0.96, 0.66, 0.06, 0.76);
		ImGui.push_color("Button", 0.22, 0.74, 0.61, 0.47);
		ImGui.push_color("ButtonHovered", 0.00, 0.48, 1.00, 1.00);
		ImGui.push_color("ButtonActive", 0.83, 0.57, 0.04, 0.76);
		ImGui.push_color("Header", 0.22, 0.74, 0.61, 0.47);
		ImGui.push_color("HeaderHovered", 0.07, 0.51, 0.92, 0.76);
		ImGui.push_color("HeaderActive", 0.96, 0.66, 0.06, 0.76);
		ImGui.push_color("Column", 0.22, 0.74, 0.61, 0.47);
		ImGui.push_color("ColumnHovered", 0.28, 0.81, 0.68, 0.76);
		ImGui.push_color("ColumnActive", 0.96, 0.66, 0.06, 1.00);
		ImGui.push_color("ResizeGrip", 0.22, 0.74, 0.61, 0.47);
		ImGui.push_color("ResizeGripHovered", 0.28, 0.81, 0.68, 0.76);
		ImGui.push_color("ResizeGripActive", 0.96, 0.66, 0.06, 0.76);
		ImGui.push_color("CloseButton", 0.00, 0.00, 0.00, 0.47);
		ImGui.push_color("CloseButtonHovered", 0.00, 0.00, 0.00, 0.76);
		ImGui.push_color("PlotLinesHovered", 0.22, 0.74, 0.61, 1.00);
		// ImGui.push_color("PlotHistogram", 0.78, 0.21, 0.21, 1.0);
		ImGui.push_color("PlotHistogram", 0.15, 0.52, 0.43, 1.00);
		ImGui.push_color("PlotHistogramHovered", 0.96, 0.66, 0.06, 1.00);
		ImGui.push_color("TextSelectedBg", 0.22, 0.74, 0.61, 0.47);
		ImGui.push_color("ModalWindowDarkening", 0.20, 0.20, 0.20, 0.69);

		Integration.new_frame();
		Profiler.load_zone();
#end

		Lm.setRandomSeed(lua.Os.time());
		var args = lua.Lib.tableToArray(untyped __lua__("arg"));
		args.splice(0, 1);
		load(args);

		Love.mousepressed  = mousepressed;
		Love.mousereleased = mousereleased;
		Love.mousemoved    = mousemoved;
		Love.wheelmoved    = wheelmoved;
		Love.textinput     = textinput;
		Love.keypressed    = keypressed;
		Love.keyreleased   = keyreleased;
		Love.resize        = resize;
		Love.focus         = focus;

		// We don't want the first frame's dt to include time taken by love.load.
		Lt.step();
	
		var dt: Float = 0;
	
		// Main loop time.
		while (true) {
			Profiler.start_frame();

			// Process events.
			window.poll_events();
			untyped __lua__('
				for name, a,b,c,d,e,f in love.event.poll() do
					if name == "quit" then
						if not {0} or not {0}() then
							return a
						end
					end
					love.handlers[name](a,b,c,d,e,f)
				end
			', quit);
	
			// Update dt, as we'll be passing it to update
			Lt.step();
			dt = Lt.getDelta();

			dt = Math.min(dt, 1/30);
			dt = Math.max(dt, 1/2000);

#if imgui
			if (Keyboard.isDown("tab")) {
				dt *= 4;
			}
#end

			// Call update and draw
			update(dt);

			if (_reload != null) {
				_game = _reload;
				_reload = null;
				La.stop();
				load(args);
				Lt.step();
				continue;
			}

			if (window.is_open()) {
				Lg.discard();
				// var bg = Lg.getBackgroundColor();
				// Lg.clear(bg.r, bg.g, bg.b, bg.a);
				Lg.origin();
				draw();

				Profiler.push_block("GC", new SegmentColor(0.5, 0.0, 0.0));
				Gc.run(false);
				Profiler.pop_block();

				Profiler.end_frame();
#if imgui
				Lg.setBlendMode(Alpha);
				Integration.render();
				Integration.new_frame();
#end
				window.present();
			}

			Lt.sleep(0.001);
		}
	}

	public static inline function change_game(game: BaseGame) {
		_reload = game;
	}

	public static inline function run(game: BaseGame) {
		_game = game;
		Love.run = real_run;
	}
}
