package backend.love;

import love.graphics.GraphicsModule as Lg;
import love.window.WindowModule as Lw;
import love.event.EventModule as Le;
import lua.Table;

class Window {
	public function new() {}
	public function open(w: Int, h: Int) {
		var flags = Table.create([], {
			vsync: true,
			msaa: 0,
			resizable: true
		});
		var ps = Lw.getDPIScale();
		Lw.setMode(w*ps, h*ps, flags);
		Lw.setTitle(Main.game_title);
	}
	public function close() {}
	public function get_framebuffer_size() {
		return {
			width: Std.int(Lg.getWidth()),
			height: Std.int(Lg.getHeight())
		};
	}
	public function is_open() {
		return Lw.isOpen();
	}
	public function present() {
		Lg.present();
	}
	public function poll_events() {
		Le.pump();
		return;
	}
}
