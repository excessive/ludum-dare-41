package components;

typedef PhysicsVars = {
	friction:  Float,
	on_ground: Bool
}

class Physics {
	public var friction:  Float = 1.5;
	public var on_ground: Bool  = false;

	public function new(?params: PhysicsVars) {
		if (params != null) {
			friction  = params.friction;
			on_ground = params.on_ground;
		}
	}
}
