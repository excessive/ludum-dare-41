package backend.love;

import haxe.io.Bytes;
import love.filesystem.FilesystemModule as LoveFs;
import lua.PairTools;

class Fs {
	public static inline function is_file(filename: String): Bool {
		return LoveFs.isFile(filename);
	}

	public static function read(filename: String, ?pos: haxe.PosInfos): Null<Bytes> {
		try {
			var data = LoveFs.read(filename);
			if (data != null && data.contents != null) {
				return Bytes.ofString(data.contents);
			}
			else {
				throw "read error";
			}
		}
		catch (e: String) {
			trace('read failure (from ${pos.fileName}:${pos.lineNumber}@${pos.methodName})');
			return null;
		}
	}

	public static function get_directory_items(path: String) {
		var items = LoveFs.getDirectoryItems(path);
		var ret = [];
		PairTools.ipairsEach(items, function(i: Int, file: String) {
			var filename = path + "/" + file;
			ret.push({
				filename: filename
			});
		});
		return ret;
	}
}
