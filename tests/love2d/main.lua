-- luamidi Testcase
-- Copyright (c)'2014 Florian Fischer^SiENcE
-- 
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation files
-- (the "Software"), to deal in the Software without restriction,
-- including without limitation the rights to use, copy, modify, merge,
-- publish, distribute, sublicense, and/or sell copies of the Software,
-- and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
-- 
-- Any person wishing to distribute modifications to the Software is
-- asked to send the modifications to the original developer so that
-- they can be incorporated into the canonical version.  This is,
-- however, not a binding provision of this license.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
-- ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
-- CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


-- Basic Midi Commands:
-- 144 - Node ON
-- 128 - Node OFF
-- 176 - change Volume [command, ?, vol (0-100)] 
-- 192 - Program change [command, patch-number]
-- midi notes from 21-108

local midi = require "luamidi"

local inputports = midi.getinportcount()
local indevicenumber = 0

local outputports = midi.getoutportcount()
local outChannel = 1
local outdevicenumber = 0
local out0 = midi.openout(outdevicenumber)
local outputdeveicename = midi.getOutPortName(outdevicenumber)

function love.load()
	if inputports > 0 then
		print("Midi Input Ports: ", inputports)
		table.foreach(midi.enumerateinports(), print)
		print( 'Receiving on device: ', luamidi.getInPortName(indevicenumber))
	else
		print("No Midi Input Ports found!")
	end
	print()

	if out0 and outputports > 0 then
		print("Midi Output Ports: ", outputports)
		table.foreach(midi.enumerateoutports(), print)
		print()
		print( 'Play on device: ', outputdeveicename )

		-- port, note, [vel], [channel]
--		midi.noteOn(0, 60, 100, 1)

		-- test tone
		-- note, [vel], [channel]
--		out0:noteOn( 60, 100, outChannel )

		-- change Volume: command, control (0-127), value (0-127)
--		out0:sendMessage( 176, 7, 100 )

		-- change Program: command, program (0-127)
		--out0:sendMessage( 192, 5 )
	else
		print("No Midi Output Ports found!")
	end
	print()
end

-- current input nodes
local a,b,c,d = nil, 60, 100, nil

function love.draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print( 'Play on device: ' .. outputdeveicename, 200, 10 )

	love.graphics.print( 'Press Q,W,E,R,T on your PC-Keyboard or connect a Midi-Keyboard to play Notes.', 200, 60 )

	love.graphics.print( 'Input devices: ' .. inputports, 200, 100 )
    love.graphics.print( 'Input', 200, 120)
    love.graphics.print( 'Command: ' ..tostring(a) .. ' Note: ' .. tostring(b) .. ' Vel.: ' .. tostring(c) .. ' delta-time: ' .. tostring(d), 200, 140)
	
	love.graphics.setColor(a or 255,b or 255,c or 255)
	love.graphics.circle('fill', (b or 0)*6, 350, (c or 0)/2 or 1, 25)
end

function love.update(dt)
	if out0 and inputports > 0 and outputports > 0 then
		-- command, note, velocity, delta-time-to-last-event (just ignore)
		a,b,c,d = midi.getMessage(indevicenumber)
		
		if a ~= nil then
			if a == 144 then
				print('Note turned ON:	', a, b, c, d)
				out0:noteOn( b, c, outChannel )
			elseif a == 128 then
				print('Note turned OFF:', a, b, c, d)
				out0:noteOff( b, c, outChannel )
			end
		end
	end
end

--					C4			D4			E4			F4			G4
local mapping = { ['q'] = 60, ['w'] = 62, ['e'] = 64, ['r']= 65, ['t']= 67 }
function love.keypressed( key, isrepeat )
	if mapping[key] then
		b,c = mapping[key], 100
		out0:noteOn( b,c, outChannel )
	end
end

function love.keyreleased(key)
	if mapping[key] then
		b,c = mapping[key], 64
		out0:noteOff( b,c, outChannel )
	end
end

function love.quit()
	midi.gc()
end
