package backend.love;

import love.timer.TimerModule as Lt;

class Timer {
	public static inline function get_time() return Lt.getTime();
	public static inline function get_delta() return Lt.getDelta();
	public static inline function get_fps() return Lt.getFPS();
	public static inline function sleep(s: Float) return Lt.sleep(s);
}
