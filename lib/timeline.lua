-- add timeline support

local s = require("sequins")
local clk = clock

local TL = {}

-- helper fns
local real = function(q)
    if s.is_sequins(q) then return q() else return q end
end
local apply = function(fn, ...) fn(...) end
local bsleep = function(v) clk.sleep(clk.get_beat_sec()*v) end
local isfn = function(f) return (type(f) == 'function') end

-- abstract fns that handle value realization & fn application
local doact = function(fn)
    fn = real(fn)
    if isfn(fn) then fn()
    else -- table of fn & args
        local t = {} -- make a copy to avoid changing sequins
        for i=1,#fn do t[i] = real(fn[i]) end
        apply(table.unpack(t))
    end
end

local dosync = function(v) clk.sync(real(v)) end
    -- FIXME dowait will gradually un-sync (need extended clocks)

local dowait = function(d, z) -- duration, zero
    local z = z+real(d)
    clk.sync(z)
    return z
end

local doalign = function(b, z)
    local now = clk.get_beats()
    local ct = now - z -- zero-ref'd current time
    b = real(b)
    if ct < b then bsleep(b-ct) end
end

local dopred = function(p)
    p = real(p) -- realize sequins value
    if isfn(p) then return p() else return p end
end

-- core timeline fns
function TL:_loop(t)
    self.coro = clk.run(function()
        clk.sync(self.lq) -- launch quantization
        local z = math.floor(clk.get_beats()) -- reference beat to stop drift
        repeat
            for i=1,#t,2 do
                doact(t[i+1])
                z = dowait(t[i], z)
            end
        until(dopred(self.p))
    end)
    return self
end

function TL.loop(t)
    return setmetatable(TL._loop({lq = 1, p = false}, t), TL)
end

-- predicate chains
-- TODO these are *only* in metamethods of created tl.loop objects
function TL:unless(pred)
    self.p = pred
    return self -- method chain
end
function TL:once()
    self.p = true
    return self -- method chain
end
function TL:times(n)
    self.p = function()
        n = n - 1
        return (n == 0) -- true at minimum count
    end
    return self -- method chain
end

-- metamethod for any created tl object
function TL:stop()
    clk.cancel(self.coro)
    self = {} -- explicitly destroy the table
end

function TL:_score(t)
    self.coro = clk.run(function()
        local now = clk.get_beats()
        local z = now + (self.lq - (now % self.lq)) -- calculate beat-zero
        for i=1,#t,2 do
            doalign(t[i], z)
            doact(t[i+1])
        end
    end)
    return self
end

function TL.score(t)
    return setmetatable(TL._score({lq = 1}, t), TL)
end

function TL.launch(q)
    local l = {lq = q}
    return setmetatable(l, TL)
end

--- metamethods
TL.mms = { stop   = TL.stop
         , unless = TL.unless
         , times  = TL.times
         , once   = TL.once
         , loop   = TL._loop
         , score  = TL._score
         }
TL.__index = TL.mms

setmetatable(TL, TL)

return TL
