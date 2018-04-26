package backend;

#if cpp
typedef NativeWindow = backend.cpp.Window;
#elseif lua
typedef NativeWindow = backend.love.Window;
#elseif hl
typedef NativeWindow = backend.hl.Window;
#end

abstract Window(NativeWindow) {
	public inline function new() this = new NativeWindow();
	public inline function open(w: Int, h: Int) this.open(w, h);
	public inline function close() this.close();
	public inline function get_size() return this.get_framebuffer_size();
	public inline function is_open() return this.is_open();
	public inline function present() return this.present();
	public inline function poll_events() return this.poll_events();
}
