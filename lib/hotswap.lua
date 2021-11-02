--- hotswap library

-- these includes are probably broken if called from within a library?
local s = require("sequins")
local tl = include('lib/timeline') -- this probably causes double-inclusion?

HS = {}

-- to add support for a new type you need: 
-- 1) add an elseif predicate for capturing the type
-- 2) give the type a single character identifier
-- 3) add a swap function to HS._swap table

HS._type = function(o)
    -- return a char representing the type
    if s.is_sequins(o) then return 's'
    -- elseif tl.is_timeline(o) then return 't'
    else print 'hotswap does not know this type'
    end
end

HS._swap = {}

HS._swap.s = function(t, v) -- sequins
    t:settable(v.data)
end

HS._swap.t = function(t, v) -- timeline
    -- TODO
    -- attempt to handle nested sequins objects
end

HS._reg = {} -- a place to register updateable sequins
HS.__index = function(self, ix)
    return HS._reg[ix][2]
end

HS.__newindex = function(self, ix, v)
    local t = HS._type(v)
    if t then
        if HS._reg[ix] then -- key already exists
            -- warning! we assume the new type matches
            HS._swap[t](HS._reg[ix][2], v)
        else -- new key
            HS._reg[ix] = {t,v} -- register with type annotation
        end
    end
end

return setmetatable(HS, HS)

------------------------------------
[[-- example usage / testing
hs = hotswap

-- sequins
hs.seq1 = s{1,2,3} -- just save the sequins into the hs.reg table
hs.seq1 = s{4,5,6} -- should replace data and copy old index

hs.seq2 = s{1,2}:every(2)
hs.seq2 = s{1,2}:every(3) -- update every counter without resetting counter

hs.seq3 = s{1,2}:every(2)
hs.seq3 = s{3,4}:every(2) -- every should be untouched

-- sequins with sequins
hs.seq4 = s{1,s{2,3}}
hs.seq4 = s{1,s{2,3,4}} -- preserve index of outer & inner sequins

hs.seq5 = s{1,s{2,3}}
hs.seq5 = s{2,s{2,3}} -- should leave inner sequins untouched (or duplicate it with index)

-- timeline
hs.tl1 = tl{3,output[1]}
hs.tl1 = tl{1,output[2]} -- should sync to next beat, regardless of 3 count

-- timeline with sequins
hs.stl1 = tl{s{1,2},output[2]}
hs.stl1 = tl{s{1,2},output[3]} -- should replace function without resetting sequins or tl-position

-- is it possible to have a timeline within a timeline
]]
