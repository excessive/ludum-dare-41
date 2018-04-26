package backend;

#if cpp
typedef BaseGame = backend.cpp.BaseGame;
#elseif lua
typedef BaseGame = backend.love.BaseGame;
#elseif hl
typedef BaseGame = backend.hl.BaseGame;
#end
