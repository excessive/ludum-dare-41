package iqm;

import love.graphics.Mesh;

typedef Bounds = {
	var min: Array<Float>;
	var max: Array<Float>;
}

typedef MeshData = {
	var first: Int;
	var count: Int;
	var material: String;
	var name: String;
	var last: Int;
}

typedef IqmFile = {
	var has_joints: Bool;
	var has_anims: Bool;
	var mesh: Mesh;
	var bounds: lua.Table<Int, Bounds>;
	var meshes: lua.Table<Int, MeshData>;
	var triangles: lua.Table<Int, Dynamic>;
}

@:luaRequire("iqm")
extern class Iqm {
	static function load(filename: String, save_data: Bool = false, preserve_cw: Bool = false): IqmFile;
	static function load_anims(filename: String): IqmAnim;
}
