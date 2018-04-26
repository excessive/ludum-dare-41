package imgui;

#if imgui
import lua.Table;

@:luaRequire("imgui")
extern class ImGui {
	@:native("GetWantCaptureKeyboard")
	static function get_want_capture_keyboard(): Bool;
	@:native("GetWantCaptureMouse")

	static function get_want_capture_mouse(): Bool;
	@:native("BeginMainMenuBar")
	static function begin_main_menu_bar(): Bool;
	@:native("EndMainMenuBar")
	static function end_main_menu_bar(): Void;
	@:native("BeginMenuBar")
	static function begin_menu_bar(): Bool;
	@:native("EndMenuBar")
	static function end_menu_bar(): Void;
	@:native("BeginMenu")
	static function begin_menu(label: String): Bool;
	@:native("EndMenu")
	static function end_menu(): Void;
	@:native("MenuItem")
	static function menu_item(label: String, ?shortcut: String, ?selected: Bool, ?enabled: Bool = true): Bool;
	@:native("PushStyleColor")
	static function push_color(key: String, r: Float, g: Float, b: Float, a: Float = 1.0): Void;
	@:native("PopStyleColor")
	static function pop_color(count: Int = 1): Void;
	@:native("PushStyleVar")
	static function push_var(key: String, x: Float, y: Float = 0): Void;
	@:native("PopStyleVar")
	static function pop_var(count: Int = 1): Void;

	@:native("GetWindowPos")
	static function get_window_pos(): RetVec2;

	@:native("GetCursorPosX")
	static function get_cursor_pos_x(): Float;
	@:native("GetCursorPosY")
	static function get_cursor_pos_y(): Float;
	@:native("SetCursorPosX")	
	static function set_cursor_pos_x(x: Float): Void;
	@:native("SetCursorPosY")
	static function set_cursor_pos_y(y: Float): Void;
	@:native("SetCursorPos")
	static function set_cursor_pos(x: Float, y: Float): Void;
	@:native("Image")
	static function image(image: Dynamic, width: Float, height: Float, u0: Float, v0: Float, u1: Float, v1: Float): Void;
	@:native("Checkbox")
	static function checkbox(label: String, enabled: Bool): Bool;
	@:native("InvisibleButton")
	static function invisible_button(id: String, width: Float = 0.0, height: Float = 0.0): Bool;
	@:native("Button")
	static function button(label: String, width: Float = 0.0, height: Float = 0.0): Bool;
	@:native("SmallButton")
	static function small_button(label: String, width: Float = 0.0, height: Float = 0.0): Bool;
	@:native("SetScrollHere")
	static function set_scroll_here(where: Float): Void;
	@:native("Bullet")
	static function bullet(): Void;
	@:native("Indent")
	static function indent(width: Float = 0): Void;
	@:native("Unindent")
	static function unindent(width: Float = 0): Void;
	@:native("SameLine")
	static function same_line(width: Float = 0): Void;
	@:native("NewLine")
	static function new_line(): Void;
	@:native("SliderInt")
	static function slider_int(label: String, value: Int, min: Int, max: Int): RetInt;
	@:native("SliderFloat")
	static function slider_float(label: String, value: Float, min: Float, max: Float): RetFloat;
	@:native("SliderFloat2")
	static function slider_float2(label: String, f1: Float, f2: Float, min: Float, max: Float): RetFloat2;
	@:native("InputText")
	private static function _input_text(label: String, text: String, width: Int): RetString;
	static inline function input_text(label: String, text: String, width: Int = 100): String {
		var ret = _input_text(label, text, width);
		return ret.str;
	}
	@:native("InputFloat")
	static function input_float(label: String, f1: Float): RetFloat;
	@:native("InputFloat2")
	static function input_float2(label: String, f1: Float, f2: Float): RetFloat2;
	@:native("InputInt2")
	static function input_int2(label: String, i1: Int, i2: Int): RetInt2;
	@:native("InputFloat3")
	static function input_float3(label: String, f1: Float, f2: Float, f3: Float): RetFloat3;
	@:native("DragFloat")
	static function drag_float(label: String, f1: Float, speed: Float, min: Float, max: Float): RetFloat;
	@:native("DragFloat2")
	static function drag_float2(label: String, f1: Float, f2: Float, speed: Float, min: Float, max: Float): RetFloat2;
	@:native("DragFloat3")
	static function drag_float3(label: String, f1: Float, f2: Float, f3: Float, speed: Float, min: Float, max: Float): RetFloat3;
	@:native("ColorEdit3")
	static function color_edit3(label: String, r: Float, g: Float, b: Float): RetFloat3;
	@:native("ColorEdit4")
	static function color_edit4(label: String, r: Float, g: Float, b: Float, a: Float): RetFloat4;
	@:native("Text")
	static function text(text: String): Void;
	@:native("Value")
	static function value(text: String, v: Float): Void;
	@:native("TextWrapped")
	static function text_wrapped(text: String): Void;
	@:native("Separator")
	static function separator(): Void;
	@:native("Spacing")
	static function spacing(): Void;
	@:native("Selectable")
	private static function _selectable(label: String, selected: Bool, flags: Null<Int>, width: Float, height: Float): Bool;
	static inline function selectable(label: String, selected: Bool, width: Float = 0.0, height: Float = 0.0): Bool {
		return _selectable(label, selected, null, width, height);
	}
	@:native("Combo")
	private static function _combo(label: String, selected: Int, items: Table<Int, String>, item_count: Int): RetCombo;
	static inline function combo(label: String, selected: Int, items: Array<String>): Int {
		var t = Table.create();
		for (v in items) {
			Table.insert(t, v);
		}
		return _combo(label, selected, t, items.length).selected;
	}

	@:native("PushItemWidth")
	static function push_item_width(width: Float): Void;
	@:native("PopItemWidth")
	static function pop_item_width(): Void;

	@:native("PushID")
	static function push_id(label: String): Void;
	@:native("PopID")
	static function pop_id(): Void;
	@:native("BeginGroup")
	static function begin_group(): Void;
	@:native("EndGroup")
	static function end_group(): Void;
	@:native("GetTreeNodeToLabelSpacing")
	static function get_tree_node_to_label_spacing(): Float;
	@:native("SetNextTreeNodeOpen")
	static function set_next_tree_node_open(state: Bool, ?cond: String): Void;
	@:native("TreeNodeEx")
	private static function _tree_node_ex(label: String, flags: Table<Int, String>): Bool;
	static inline function tree_node(label: String, default_open: Bool = false, ?flags: Table<Int, String>): Bool {
		if (default_open) {
			set_next_tree_node_open(true, "FirstUseEver");
		}
		return _tree_node_ex(label, flags);
	}
	@:native("TreePop")
	static function tree_pop(): Void;

	@:native("IsItemClicked")
	static function is_item_clicked(button: Int): Bool;

	@:native("IsItemActive")
	static function is_item_active(button: Int): Bool;

	@:native("PlotLines")
	private static function _plot_lines(label: String, points: Table<Int, Float>, count: Int, offset: Float, overlay_text: String, x_max: Float, y_max: Float, w: Float, h: Float): Void;

	static inline function plot_lines(label: String, points: Array<Float>, offset: Float, overlay_text: String, x_max: Float, y_max: Float, w: Float, h: Float): Void {
		var t = Table.create();
		for (i in 0...points.length) {
			t[i+1] = points[i];
		}
		return _plot_lines(label, t, points.length, offset, overlay_text, x_max, y_max, w, h);
	}

	@:native("Begin")
	static function begin(label: String, ?initial: Null<Bool>, ?flags: Table<Int, String>): Bool;
	@:native("End")
	static function end(): Void;
	@:native("BeginDockspace")
	static function begin_dockspace(): Void;
	@:native("EndDockspace")
	static function end_dockspace(): Void;
	@:native("SetDockActive")
	static function set_dock_active(): Void;
	@:native("SetNextDock")
	static function set_next_dock(slot: String): Void;
	@:native("BeginDock")
	static function begin_dock(label: String, ?opened: Bool, ?flags: Table<Int, String>): Bool;
	@:native("EndDock")
	static function end_dock(): Void;
	@:native("BeginChild")
	static function begin_child(label: String, width: Float = 0.0, height: Float = 0.0, border: Bool = false, ?flags: Table<Int, String>): Bool;
	@:native("EndChild")
	static function end_child(): Void;
	@:native("SetNextDockSplitRatio")
	static function set_next_dock_split_ratio(x: Float = 0.5, y: Float = 0.5): Void;
	@:native("SetNextWindowPos")
	static function set_next_window_pos(x: Float, y: Float, ?initial: Bool): Void;
	@:native("SetNextWindowSize")
	static function set_next_window_size(width: Float, height: Float, ?initial: Bool): Void;
	@:native("GetContentRegionMax")
	private static function _get_content_region_max(): RetVec2;
	static inline function get_content_region_max(): Array<Float> {
		var v = _get_content_region_max();
		return [ v.f1, v.f2 ];
	}

}

@:multiReturn
extern class RetVec2 {
	var f1: Float;
	var f2: Float;
}

@:multiReturn
extern class RetCombo {
	var status: String;
	var selected: Int;
}

@:multiReturn
extern class RetString {
	var status: String;
	var str: String;
}

@:multiReturn
extern class RetFloat {
	var status: Bool;
	var f1: Float;
}

@:multiReturn
extern class RetFloat2 {
	var status: String;
	var f1: Float;
	var f2: Float;
}

@:multiReturn
extern class RetFloat3 {
	var status: String;
	var f1: Float;
	var f2: Float;
	var f3: Float;
}

@:multiReturn
extern class RetFloat4 {
	var status: String;
	var f1: Float;
	var f2: Float;
	var f3: Float;
	var f4: Float;
}

@:multiReturn
extern class RetInt {
	var status: String;
	var i1: Int;
}

@:multiReturn
extern class RetInt2 {
	var status: String;
	var i1: Int;
	var i2: Int;
}

#end
