-- luamidi Testcase
-- Copyright (c)'2014 Florian Fischer
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
-- 144-159 - Node ON (for each of the 16 midi channels)
-- 128-143 - Node OFF (for each of the 16 midi channels)
-- 176-191 - Control Commands (for each of the 16 midi channels)
-- 192-207 - Program change (for each of the 16 midi channels)

-- Each channel can receive it's own node on, node off, ccomands and program changes
-- You can play on as many output devices, and channels at the same time!

-- Midi documentation
-- http://computermusicresource.com/MIDI.Commands.html
-- http://www.midi.org/techspecs/midispec.php
-- http://rakarrack.sourceforge.net/midiic.html
-- https://ccrma.stanford.edu/~craig/articles/linuxmidi/misc/essenmidi.html
-- https://www.nyu.edu/classes/bello/FMT_files/9_MIDI_code.pdf

-- CC comamands
-- http://www.indiana.edu/~emusic/cntrlnumb.html

local midi = require "luamidi"

local inputports = midi.getinportcount()
local indevicenumber = 0
local in0 = nil

local outputports = midi.getoutportcount()
local outChannel = 1	-- (channels start with 0-15)
local outdevicenumber = 0
local out0 = midi.openout(outdevicenumber)
local outputdeveicename = midi.getOutPortName(outdevicenumber)

function love.load()
	if inputports > 0 then
		print("Midi Input Ports: ", inputports)
		table.foreach(midi.enumerateinports(), print)
		print( 'Receiving on device: ', luamidi.getInPortName(indevicenumber))
		-- not needed for this demo
--		in0 = midi.openin(indevicenumber)
	else
		print("No Midi Input Ports found!")
	end
	print()

	if out0 and outputports > 0 then
		print("Midi Output Ports: ", outputports)
		table.foreach(midi.enumerateoutports(), print)
		print()
		print( 'Play on device: ', outputdeveicename )

		-- change Program: 16 midi channels (192-207), program (0-127), - not used -
		out0:sendMessage( 192+outChannel, 1, 0 )	-- on midi channel 1, change program to 1

		out0:sendMessage( 192+outChannel+1, 90, 0 )	-- on midi channel 2, change program to 120


		-- change Control Mode: 16 midi channels (176-191), control (0-127), control value (0-127)
		out0:sendMessage( 176+outChannel, 7, 50)	-- on midi channel 1, change volume, to 80

		----------------------------------------------------
		-- Play notes using the following two possibilities:
		----------------------------------------------------
		
		-- Play note: midi port, note, [vel], [channel]
		midi.noteOn(0, 60, 100, outChannel) -- play on port 0, note 10, velocity 80, on midi channel 1

		-- or
		
		-- Play note: note, [vel], [channel]
		out0:noteOn( 10, 10, outChannel+1 ) -- play on choosen port out0, note 60, velocity 100, on channel outChannel
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
			if a == 144 then	-- listen for Note On on First Midi Channel
				print('Note turned ON:	', a, b, c, d)
				out0:noteOn( b, c, outChannel )
			elseif a == 128 then	-- listen for Note Off on First Midi Channel
				print('Note turned OFF:', a, b, c, d)
				out0:noteOff( b, c, outChannel )
			elseif a == 176 then	-- if channel volume is changed
				print('Channel Volume changed (Ch/Vol):', b, c)
				out0:sendMessage( 176+outChannel, 7, c)
			else
				-- other messages
				print('SYSTEM:', a,b,c,d)
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
