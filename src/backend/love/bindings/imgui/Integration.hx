package imgui;

#if imgui
@:luaRequire("imgui")
extern class Integration {
	@:native("Render")
	static function render(): Void;
	@:native("ShutDown")
	static function shutdown(): Void;
	@:native("NewFrame")
	static function new_frame(): Void;
	@:native("ShowStyleEditor")
	static function show_style_editor(): Void;
	@:native("SetGlobalFontFromFileTTF")
	static function set_global_font(path: String, size_pixels: Float, spacing_x: Float = 0, spacing_y: Float = 0, oversample_x: Float = 1, oversample_y: Float = 1): Void;
	@:native("MouseMoved")
	static function mousemoved(x: Float, y: Float): Void;
	@:native("MousePressed")
	static function mousepressed(button: Float): Void;
	@:native("MouseReleased")
	static function mousereleased(button: Float): Void;
	@:native("WheelMoved")
	static function wheelmoved(y: Float): Void;
	@:native("KeyPressed")
	static function keypressed(key: String): Void;
	@:native("KeyReleased")
	static function keyreleased(key: String): Void;
	@:native("TextInput")
	static function textinput(text: String): Void;
}
#end
