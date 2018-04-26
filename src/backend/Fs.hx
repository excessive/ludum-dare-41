package backend;

#if lua
typedef Fs = backend.love.Fs;
#else
typedef Fs = backend.hl.Fs;
#end
