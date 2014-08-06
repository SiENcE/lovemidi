lovemidi
========

lovemidi is a project to give LÖVE a midi i/o interface. lovemidi is based on luamidi and rtmidi as interface library.

LÖVE/Lua compatibility
======================

* The current version is compatible with LÖVE 0.9.1, LÖVE 0.8.0, LÖVE 0.72 and Lua 5.1.x
* For x86 choose luamidi.dll
* For win64 choose luamidi.dll_64 and rename to luamidi.dll


* The current binary is compiled with VS2012 (as LÖVE 0.9.1). Other LÖVE/Lua could bring different Visual Studios runtimes.
* If the library does not work, you have to install the Visual Studio 2012 [Runtime](http://www.microsoft.com/en-US/download/details.aspx?id=30679).

Example
=======

Output (send Midi Data to Output-Port 0)
```lua
-- initialize the library
local midi = require "luamidi"

-- count output-ports
print("Midi Output Ports: ", midi.getoutportcount() )

-- play a note on output-port 0 on channel 1
-- port, note, [vel], [channel]
midi.noteOn(0, 60, 50, 1)

-- deinitialize library
midi.gc()
```

Input (receive Midi Data from Input-Port 0)
```lua
-- initialize the library
local midi = require "luamidi"

-- look for available input ports
print("Midi Input Ports: ", midi.getinportcount())

if midi.getinportcount() > 0 then
	table.foreach(midi.enumerateinports(), print)
	print( 'Receiving on device: ', luamidi.getInPortName(0))
	print()

	local a, b, c, d = nil
	while true do
		-- recive midi command from input-port 0
		-- command, note, velocity, delta-time-to-last-event (just ignore)
		a,b,c,d = midi.getMessage(0)
		
		if a ~= nil then
			-- look for an NoteON command
			if a == 144 then
				print('Note turned ON:	', a, b, c, d)
			-- look for an NoteOFF command
			elseif a == 128 then
				print('Note turned OFF:', a, b, c, d)
			end
		end
	end
end

-- deinitialize library
midi.gc()
```

For more advanced examples please look into the tests/ folder.

Installation
============

Just add the right luamidi.dll (for LÖVE x86) or luamidi.dll_64 (rename to luamidi.dll) (for LÖVE win64) to your project.

References
============

lovemidi uses luamidi
luamidi used rtmidi for cross platform midi compatibilty Linux/MacOSX/Windows
