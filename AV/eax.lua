local field2D = require("field2D")
local draw2D = require "draw2D"
local gl = require "gl"
local audioin = require "audioin"
local ffi = require "ffi"
local ttf = 1

local dim = 25
local game = field2D.new(dim, 256)
local past = field2D.new(256, dim)

audioin.Init()

ffi.cdef[[
void Sleep(int ms);
int poll(struct pollfd *fds, unsigned long nfds, int timeout);
]]

function sleep(s)
  ffi.C.Sleep(s*1000)
end


function init_game_cell(x, y)
	if math.random() < 0.3 then
		return 0
	else
		return 1
	end
end
game:set(init_game_cell)

function update_game_cell(x, y)
	local N = past:get(x, y+1)
	local S = past:get(x, y-1)
	local E = past:get(x+1, y)
	local W = past:get(x-1, y)
	local NE = past:get(x+1, y-1)
	local NW = past:get(x-1, y-1)
	local SE = past:get(x+1, y-1)
	local SW = past:get(x-1, y-1)
	
	local total = N + S + E + W + NE + NW + SE + SW	
	local C = past:get(x, y)
	
	if C == 1 then
		-- currently alive:
		if total < 1 and math.random() < .9 then
			return 1
		elseif total > 1 then
			return 0
		else
			return 1
		end
	else 
		-- currently dead:
		if total == 1 then
			return 1
    else
			return 0
		end
	end
end

function mouse(event, button, x, y)
	local column = x * dim
	local row = y * dim
	local value = 1
	for i = 1, 10 do
		local row1 = row + math.random(5)-5
		local col1 = column + math.random(5)-3
		game:set(value, col1, row1)
	end
end

function update()
  fft = audioin.ExecuteFFT(1,32)
	if fft[10] > 300 then ttf = fft[10]; print(ttf) end
  past, game = game, past
	game:set(update_game_cell)
end 

function draw()
	gl.Disable(gl.DEPTH_TEST)
  draw2D.push()
	
  draw2D.color(0,0,(ttf/1000)+.3)
	game:draw()
  
	draw2D.color(0,(ttf/1000)+.3,0)
	past:draw()
  
  draw2D.pop()
end
