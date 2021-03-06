-------------------------------------------------------------------------------
--- Package     : Fleece - fast Lua to JSON module                          ---
--- File        : test/bench-fleece.lua                                     ---
--- Description : Fleece benchmarks: random tables, speed clocked           ---
--- Version     : 0.3.1 / alpha                                             ---
--- Copyright   : 2011 Henning Diedrich, Eonblast Corporation               ---
--- Author      : H. Diedrich <hd2010@eonblast.com>                         ---
--- License     : see file LICENSE                                          ---
--- Created     :    Feb 2011                                               ---
--- Changed     : 18 Mar 2011                                               ---
-------------------------------------------------------------------------------
---                                                                         ---
---  This runs only Fleece. Other examples make comparisons to:             ---
---                                                                         ---
---  JSON4 0.9.50: (aka JSON4Lua, JSON for Lua) http://json.luaforge.net/   ---
---  LuaJSON 1.1: (aka luajsonlib) http://luaforge.net/projects/luajsonlib/ ---
---                                                                         ---
---  Use: lua test/bench-fleece.lua                                         ---
---  Or:  make bench                                                        ---
---                                                                         ---
-------------------------------------------------------------------------------

print()
print("Fleece Benchmarks (10,000 iterations)")
print("=====================================")
print("A couple of random tables are created and speed is clocked.")
print("You should have built fleece first with 'make <PLATFORM>', ")
print("and now be in the fleece root directory.")

package.cpath="src/?.so"
fleece = require("fleece")

function printf(...)
  io.write(string.format(...))
end

function nanosecs_per(time, cycles)
	return time * 1000000000 / cycles
end

function microsecs_per(time, cycles)
	return time * 1000000 / cycles
end

local abc = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'}
function randstr(i)
      local r = {}
      local length = math.random(1,20)
      local i
      for i = 1, length do
         r[i] = abc[math.random(1, 26)]
      end

      return table.concat(r)
 end

local t = {}
local function measure(prepP, prepare, actionP, action)

  local items  = 1000
  local cycles = 10000
  local clock  = os.clock

print("-------------------------------------------------------------------------")
  printf("i=[1..%d] in %-12s for %d cycles of %-12s\n", items, prepP, cycles, actionP)
  print(". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .")
  io.write("prep table ... ")

  t = {}
  local i = 1
  local size = 0
  while(i <= items) do prepare(i); i = i + 1 end

  i = 1
  local last = nil
  io.write("action ... ")
  local tm = clock()
  while(i <= cycles) do last = action(i); i = i + 1 end
  tm = clock() - tm
  if tm ~= 0 then
      mark = nanosecs_per(tm, cycles * items)
	  printf("%10.0f nanosec/element => %3.0fM elements/sec \n", mark,
	    math.floor(1000 / mark))
  else
	  printf("%dx %-12s ** sample too small, could not measure, increase 'cycles' in this script \n", cycles, actionP)
  end
end
if(_PATCH) then io.write(_PATCH) else io.write(_VERSION .. ' official') end
print(" - Fleece 0.3.1")


measure("t[i]=i",
		function(i) t[i] = i end,
		"fleece.json(t)",
		function(i) fleece.json(t) end
		)

measure("t['x'..i]=i",
		function(i) t['x'..i] = i end,
		"fleece.json(t)",
		function(i) fleece.json(t) end
		)		

measure("t[i]=randstr(i)",
		function(i) t[i] = randstr(i) end,
		"fleece.json(t)",
		function(i) fleece.json(t) end
		)		
		
measure("t[randstr(i)]=randstr(i)",
		function(i) t[randstr(i)] = randstr(i) end,
		"fleece.json(t)",
		function(i) fleece.json(t) end
		)
print("-------------------------------------------------------------------------")
print("There are more benchmarks. Try bench2, bench3a, bench7a.")
print("Run 'make' w/o parameters for details, or see test/README.md.")
print("Repeat runs will differ.")
