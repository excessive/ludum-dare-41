package systems;

import backend.Profiler.SegmentColor;
import haxe.crypto.Crc32;
import haxe.io.Bytes;

class System {
	public var PROFILE_NAME: String;
	public var PROFILE_COLOR: SegmentColor;
	public function new() {
		var cn = Type.getClassName(Type.getClass(this));
		var idx = cn.lastIndexOf(".") + 1;
		PROFILE_NAME = cn.substr(idx);

		var crc = Crc32.make(Bytes.ofString(cn));
		var r = ((crc >> 24) & 0xff) / 255.0;
		var g = ((crc >> 16) & 0xff) / 255.0;
		var b = ((crc >>  8) & 0xff) / 255.0;
		PROFILE_COLOR = new SegmentColor(r, g, b);
	}
	public function filter(e: Entity): Bool { return false; }
	public function update(entities: Array<Entity>, dt: Float) {}
	public function process(e: Entity, dt: Float) {}
}
