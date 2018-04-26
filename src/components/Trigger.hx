package components;

enum TriggerState {
	Entered;
	Inside;
	Left;
}

enum TriggerType {
	Radius;
	Volume;
	RadiusInFront;
}

typedef TriggerCb = Entity->TriggerState->Void;

class Trigger {
	public var cb: TriggerCb;
	public var type: TriggerType;
	public var range: Float;
	public var max_angle: Float;
	public var inside: Bool = false;
	public function new(_cb: TriggerCb, _type: TriggerType, _range: Float, _max_angle: Float = 0.5) {
		this.cb = _cb;
		this.type = _type;
		this.range = _range;
		this.max_angle = _max_angle;
	}
}
