package backend;

#if cpp
typedef NativeGameLoop = backend.cpp.GameLoop;
#elseif lua
typedef NativeGameLoop = backend.love.GameLoop;
#elseif hl
typedef NativeGameLoop = backend.hl.GameLoop;
#end

abstract GameLoop(NativeGameLoop) {
	public static inline function run(game: BaseGame) return NativeGameLoop.run(game);
	public static inline function change_game(game: BaseGame) return NativeGameLoop.change_game(game);
}
