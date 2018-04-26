package backend;

import math.Vec3;

#if lua
typedef NativeAudio = love.audio.AudioModule;
#elseif hl
typedef NativeAudio = backend.hl.Audio;
#end

abstract Audio(NativeAudio) {
	public static inline function setPosition(position: Vec3) {
		NativeAudio.setPosition(position.x, position.y, position.z);
	}
}
