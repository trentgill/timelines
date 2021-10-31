-- testing norns/crow libs

local tl = include('lib/timeline')
local s = include('lib/sequins_extended')
local fox = include('lib/foxdot')

function init()
    clock.tempo = 120
    
    fox['a'] = function() print'a' end
    fox['b'] = function() print'b' end
    mytl = tl.loop{2, {fox, s"aab"}}
    -- mytl = tl.fox{1/2, s"+ - ++ -"} -- proposed optional sugar
    
    -- mytl = tl.launch(4):loop
    --     { 2, function() print'2' end
    --     , 3, function() print'3' end
    --     }:times(3)
--   tl.score{ 0, function() print'0' end
--           , 1, function() print'1' end
--           , 2, function() print'2' end
--           }
end

-- tl.loop & tl.score both work & are well aligned to the clock
-- tl.launch can be placed up front and chained to loop & score
-- :unless, :once, :times all work to modify :loop
-- :unless can take a sequins-of-booleans or function-returning-boolean
-- :stop will cleanup a running timeline
