import backend.GameLoop;
import backend.BaseGame;

import love.graphics.GraphicsModule as Lg;
import love.graphics.Image;
import love.audio.AudioModule as La;
import love.audio.Source;
import timer.Timer;

import ui.Anchor;

class Splash extends BaseGame {
	var delay = 5.5;
	var overlay = {
		opacity: 1.0
	};
	var logos: {
		l3d:   Image,
		exmoe: Image
	};
	var bgm: {
		volume: Float,
		music: Source
	}
	var lock = true;
	var finished = false;

	override function load(args) {
		bgm = {
			music: La.newSource("assets/splash/love.ogg", Static),
			volume: 0.25
		}

		logos = {
			l3d: Lg.newImage("assets/splash/logo-love3d.png"),
			exmoe: Lg.newImage("assets/splash/logo-exmoe.png")
		}

		Timer.after(0.25, function(f) {
			lock = false;
		});

		// BGM
		Timer.script(function(wait) {
			bgm.music.setVolume(bgm.volume);
			bgm.music.play();
			wait(delay);
			Timer.tween(1.5, bgm, { volume: 0 }, InQuad, function() {
				bgm.music.stop();
			});
		});

		// Overlay fade
		Timer.script(function(wait) {
			Timer.tween(1.5, overlay, { opacity: 0 }, Cubic);
			wait(delay);
			Timer.tween(1.25, overlay, { opacity: 1 }, OutCubic, function() {
				finished = true;
			});
		});
	}

	override function keypressed(key: String, scan: String, isrepeat: Bool) {
		if (lock) {
			return;
		}
		finished = true;
	}

	override function update(window, dt: Float) {
		Anchor.update(window);
		Timer.update(dt);

		bgm.music.setVolume(bgm.volume);

		if (finished) {
			bgm.music.stop();
			GameLoop.change_game(new Main());
		}
	}

	override function draw(window) {
		Lg.clear(30/255, 30/255, 44/255, 1);

		var cx = Anchor.center_x;
		var cy = Anchor.center_y;

		var lw = logos.exmoe.getWidth();
		var lh = logos.exmoe.getHeight();
		Lg.setColor(1, 1, 1, 1);
		Lg.draw(logos.exmoe, cx-lw/2, cy-lh/2 - 84);

		var lw = logos.l3d.getWidth();
		var lh = logos.l3d.getHeight();
		Lg.draw(logos.l3d, cx-lw/2, cy-lh/2 + 64);

		// Full screen fade, we don't care about logical positioning for this.
		Lg.setColor(0, 0, 0, overlay.opacity);
		Lg.rectangle(Fill, 0, 0, Lg.getWidth(), Lg.getHeight());
	}
}
