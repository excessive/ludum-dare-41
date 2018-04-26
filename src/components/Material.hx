package components;

import math.Vec3;

typedef Texture = {}

typedef Material = {
	var color: Vec3;
	var emission: Float;
	var metalness: Float;
	var roughness: Float;
	var vampire: Bool;
	@:optional var triplanar: Bool;
	@:optional var shadow: Bool;
	@:optional var textures: {
		@:optional var albedo: Texture;
		@:optional var roughness: Texture;
		@:optional var metalness: Texture;
		@:optional var scale: Float;
	}
}
