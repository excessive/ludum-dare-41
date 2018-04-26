package render;

import love.graphics.GraphicsModule as Lg;
import love.graphics.Shader as LgShader;

import utils.CacheResource;
import haxe.Resource.getString as get_res;

typedef ShaderCache = CacheResource<LgShader, Bool>;

class Shader {
	static var cache = new ShaderCache(function(filename: String, _) {
		return Lg.newShader(filename);
	});
	public static function init() {
		cache.inject("debug",   Lg.newShader(get_res("shader_debug")));
		cache.inject("sky",     Lg.newShader(get_res("shader_sky")));
		cache.inject("post",    Lg.newShader(get_res("shader_post")));
		cache.inject("basic",   Lg.newShader(get_res("shader_basic")));
		cache.inject("terrain", Lg.newShader(get_res("shader_terrain")));
		cache.inject("fxaa",    Lg.newShader(get_res("shader_fxaa")));
	}
	public static function get(name: String): LgShader {
		var shader = cache.get(name, false);
		if (shader == null) {
			throw "Invalid shader key: " + name;
		}
		return shader;
	}
}
