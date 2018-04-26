package backend.love;

import backend.Window as PlatformWindow;

class BaseGame {
	public function new() {}
	public function load(args: Array<String>) {}
	public function update(window: PlatformWindow, dt: Float) {}
	public function draw(window: PlatformWindow) {}
	/** return false to accept quitting **/
	public function quit(): Bool { return false; }
	public function mousepressed(x: Float, y: Float, button: Int) {}
	public function mousereleased(x: Float, y: Float, button: Int) {}
	public function mousemoved(x: Float, y: Float, dx: Float, dy: Float) {}
	public function wheelmoved(x: Float, y: Float) {}
	public function textinput(str: String) {}
	public function keypressed(key: String, scan: String, isrepeat: Bool) {}
	public function keyreleased(key: String, scan: String) {}
	public function resize(w: Float, h: Float) {}
}
