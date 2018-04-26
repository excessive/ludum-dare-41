import love.audio.AudioModule as La;
import love.audio.Source;

class Sfx {
	public static var bonk:    Source;
	public static var wub:     Source;
	public static var spawn:   Source;
	public static var respawn: Source;
	public static var timeout: Source;

	public static function init() {
		if (bonk == null) {
			bonk = La.newSource("assets/sfx/bonk.ogg", Static);
		}

		if (wub == null) {
			wub = La.newSource("assets/sfx/wub.ogg", Static);
		}

		if (spawn == null) {
			spawn = La.newSource("assets/sfx/spawn.ogg", Static);
			spawn.setVolume(0.5);
		}

		if (respawn == null) {
			respawn = La.newSource("assets/sfx/respawn.ogg", Static);
			respawn.setVolume(0.5);
		}

		if (timeout == null) {
			timeout = La.newSource("assets/sfx/timeout.ogg", Static);
			timeout.setVolume(0.5);
		}
	}

	public static function wub_for_speed(speed: Float) {
		wub.setPitch(1);
		wub.setVolume(0.35);

		if (speed < 50) {
			wub.setPitch(0.9);
			wub.setVolume(0.3);
		}

		if (speed < 40) {
			wub.setPitch(0.8);
			wub.setVolume(0.25);
		}

		if (speed < 30) {
			wub.setPitch(0.7);
			wub.setVolume(0.2);
		}

		if (speed < 20) {
			wub.setPitch(0.6);
			wub.setVolume(0.15);
		}

		if (speed < 10) {
			wub.setPitch(0.5);
			wub.setVolume(0.1);
		}

		if (speed < 5) {
			wub.setPitch(0.4);
			wub.setVolume(0.075);
		}

		if (speed >= 5) {
			wub.play();
		}
	}
}
