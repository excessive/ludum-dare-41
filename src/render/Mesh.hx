package render;

import haxe.io.Bytes;
import math.Vec3;
import math.Triangle;

#if lua

import math.Utils;
import love.graphics.Mesh as LgMesh;
import love.graphics.GraphicsModule as Lg;
import love.graphics.SpriteBatchUsage;
import love.graphics.MeshDrawMode;
import lua.Table;

#elseif hl

import sdl.GL;
import sdl.GL.Buffer;
import sdl.GL.VertexArray;

#end

typedef VertexFormat = {
	name: String,
	type: String,
	count: Int,
	stride: Int,
	normalize: Bool
};

enum PrimitiveMode {
	Triangles;
	Lines;
	Points;
}

enum UsageMode {
	Static;
	Collision;
	Dynamic;
	Stream;
}

#if lua
abstract Mesh(LgMesh) {
	@:to
	public function to_mesh(): LgMesh {
		return this;
	}

	@:from
	public static function from_mesh(m: LgMesh): Mesh {
		return cast m;
	}

	public function new(fmt: Array<VertexFormat>, data: Array<Bytes>, indices: Bytes, ?usage: UsageMode, ?mode: Int, ?reserve: Int = 0, ?pos: haxe.PosInfos) {
	// @:overload(function (vertexformat:Table<Dynamic,Dynamic>, vertices:Table<Dynamic,Dynamic>, ?mode:MeshDrawMode, ?usage:SpriteBatchUsage) : Mesh {})
	// @:overload(function (vertexformat:Table<Dynamic,Dynamic>, vertexcount:Float, ?mode:MeshDrawMode, ?usage:SpriteBatchUsage) : Mesh {})
		var love_fmt = Table.create();
		var love_mode: MeshDrawMode = Triangles;
		var love_usage: SpriteBatchUsage = Static;
		var limit = reserve;

		inline function gltf2lovename(type: String) {
			return switch (type) {
				case "VertexTexCoord0": "VertexTexCoord";
				default: type;
			}
		}

		inline function gltf2lovetype(type: String) {
			return switch (type) {
				case "short": "unorm16";
				default: type;
			}
		}

		for (i in 0...fmt.length) {
			var component = fmt[i];
			limit = Std.int(Utils.max(limit, data[i].length));
			var name = gltf2lovename(component.name);
			var type = gltf2lovetype(component.type);
			var t = untyped __lua__(
				"{ {0}, {1}, {2}, {3} }",
				name,
				type,
				component.count,
				component.normalize
			);
			love_fmt[i+1] = t;
		}

		this = Lg.newMesh(love_fmt, limit, love_mode, love_usage);

		// TODO: set vertices
	}
}

#elseif hl
class Mesh {
	var buffers: Array<Buffer> = [];
	var format: Array<VertexFormat> = [];
	var vao: VertexArray;
	public var triangles(default, null): Array<Triangle> = [];
	public var count(default, null): Int;
	public var index_mode(default, null): Int;
	public var prim_mode(default, null): Int;

	public var handle(get, never): VertexArray;
	inline function get_handle() return vao;

	inline function type2gl(type: String) {
		return switch(type) {
			case "short": GL.UNSIGNED_SHORT;
			case "byte": GL.UNSIGNED_BYTE;
			case "int": GL.UNSIGNED_INT;
			default: GL.FLOAT;
		}
	}

	public function new(fmt: Array<VertexFormat>, data: Array<Bytes>, indices: Bytes, ?usage: UsageMode, ?mode: Int, ?reserve: Int = 0, ?pos: haxe.PosInfos) {
		if (usage == null) {
			usage = Static;
		}
		if (mode == null) {
			mode = GL.UNSIGNED_SHORT;
		}

		format = fmt;

		var gl_usage = switch (usage) {
			case Collision: GL.STATIC_DRAW;
			case Static: GL.STATIC_DRAW;
			case Dynamic: GL.DYNAMIC_DRAW;
			case Stream: GL.STREAM_DRAW;
		}

		var div = switch (mode) {
			case GL.UNSIGNED_BYTE: 1;
			case GL.UNSIGNED_SHORT: 2;
			case GL.UNSIGNED_INT: 4;
			default: 4;
		}

		vao = GL.createVertexArray();
		GL.bindVertexArray(vao);
		for (i in 0...fmt.length) {
			var buf = GL.createBuffer();
			GL.bindBuffer(GL.ARRAY_BUFFER, buf);
			var reserve_bytes = Math.ceil(Math.max(data[i].length, reserve*fmt[i].stride));
			GL.bufferData(GL.ARRAY_BUFFER, reserve_bytes, null, gl_usage);
			GL.enableVertexAttribArray(i);
			buffers.push(buf);
		}

		Utils.check_error();

		var ibo = GL.createBuffer();
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, ibo);
		GL.bufferData(
			GL.ELEMENT_ARRAY_BUFFER,
			indices == null ? Std.int(reserve * div) : indices.length,
			null,
			gl_usage
		);
		buffers.push(ibo);
		prim_mode = GL.TRIANGLES;
		index_mode = mode;
		count = Std.int((indices == null ? -1 : indices.length) / div);

		set_buffers(data);
		set_indices(indices, count);

		if (usage == Collision) {
			inline function get_position(positions: haxe.io.Bytes, base: Int): Vec3 {
				return new Vec3(
					positions.getFloat(base+0),
					positions.getFloat(base+4),
					positions.getFloat(base+8)
				);
			}
			inline function get_index(indices: haxe.io.Bytes, mode: Int, base: Int) {
				var idx = base*mode;
				return switch (mode) {
					case 1: indices.get(idx);
					case 2: indices.getUInt16(idx);
					case 4: indices.getInt32(idx);
					default: trace("AAAAAAAAAAA"); 0;
				}
			}
			var p = data[0];
			var ib = indices;
			for (i in 0...Std.int(count/3)) {
				var idx = i*3;
				var stride = fmt[0].stride;
				var tri = Triangle.without_normal(
					get_position(p, get_index(ib, div, idx)*stride),
					get_position(p, get_index(ib, div, idx+1)*stride),
					get_position(p, get_index(ib, div, idx+2)*stride)
				);
				triangles.push(tri);
			}
		}
	}

	public function set_indices(indices: Bytes, idx_count: Int = -1) {
		if (indices == null || idx_count == 0 || indices.length == 0) {
			count = 0;
			return;
		}
		var ibo = buffers[buffers.length-1];
		GL.bindVertexArray(vao);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, ibo);
		GL.bufferSubData(GL.ELEMENT_ARRAY_BUFFER, 0, hl.Bytes.fromBytes(indices), 0, indices.length);
		Utils.check_error();

		if (idx_count >= 0) {
			count = idx_count;
		}
	}

	public function set_buffers(data: Array<Bytes>) {
		GL.bindVertexArray(vao);
		var len = Std.int(math.Utils.min(data.length, buffers.length));
		for (i in 0...len) {
			var new_data = data[i];
			if (new_data == null) {
				continue;
			}
			var component = format[i];
			GL.bindBuffer(GL.ARRAY_BUFFER, buffers[i]);
			GL.bufferSubData(GL.ARRAY_BUFFER, 0, hl.Bytes.fromBytes(new_data), 0, new_data.length);
			GL.vertexAttribPointer(i, component.count, type2gl(component.type), component.normalize, component.stride, 0);
		}
		Utils.check_error();
	}

	public function destroy() {
		for (buf in buffers) {
			GL.deleteBuffer(buf);
		}
		GL.deleteVertexArray(vao);
	}

	public function draw() {
		GL.bindVertexArray(vao);
		GL.drawElementsInstanced(prim_mode, count, index_mode, 0, 1);
	}
}

#end
