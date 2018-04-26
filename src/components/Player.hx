package components;

import math.Vec3;
import math.Quat;

class Player {
	public var spin: Quat = new Quat(0, 0, 0, 1);
	public var last_position = new Vec3(0, 0, 0);
	public var lag_position = new Vec3(0, 0, 0);
	public var lag_tilt = new Quat(0, 0, 0, 1);
	public var pillows: Int = 0;
	public inline function new() {}
}
