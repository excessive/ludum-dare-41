io.stdout:setvbuf("no")
local path = love.filesystem.getRequirePath()
path = path .. ";libs/?.lua"
path = path .. ";libs/?/init.lua"
love.filesystem.setRequirePath(path)

require "love.system"
require "love.window"

local function split(str, sep)
	local patternescape = function(str)
		return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
	end
	local function array(...)
		local t = {}
		for x in ... do t[#t + 1] = x end
		return t
	end
	if not sep then
		return lume.array(str:gmatch("([%S]+)"))
	else
		assert(sep ~= "", "empty separator")
		local psep = patternescape(sep)
		return array((str..sep):gmatch("(.-)("..psep..")"))
	end
end

if love.system.getOS() == "Linux" then
	local f         = io.popen("gsettings get org.gnome.desktop.interface scaling-factor")
	local _scale    = split(f:read() or "it's 1", " ")
	local dpi_scale = _scale[2] and tonumber(_scale[2]) or 1.0

	if dpi_scale >= 0.5 then
		love.window.toPixels = function(v)
			return v * dpi_scale
		end

		love.window.getDPIScale = function()
			return dpi_scale
		end
	end
end

function love.conf(t)
	t.version = "11.0"
	t.window = false
	t.modules.physics = false
	t.gammacorrect  = true
end
