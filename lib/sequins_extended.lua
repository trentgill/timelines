--- sequins_extended
-- copy method
-- string support
-- mutable indices

S = require 'sequins'

-- convert a string to a table of chars
function totable(t)
    if type(t) == 'string' then
        local tmp = {}
        t:gsub('.', function(c) table.insert(tmp,c) end)
        return tmp
    end
    return t
end

-- copied here for redefining .new
function wrap_index(s, ix) return ((ix - 1) % s.length) + 1 end

-- just adds totable to .new
function S.new(t)
    t = totable(t) -- convert a string to a table of chars
    -- wrap a table in a sequins with defaults
    local s = { data   = t
              , length = #t -- memoize table length for speed
              , set_ix = 1 -- force first stage to start at elem 1
              , ix     = 1 -- current val
              , n      = 1 -- can be a sequin
              }
    s.action = {up = s}
    setmetatable(s, S)
    return s
end

-- can this be generalized to cover every/count/times etc
function S.setdata(self, t)
    -- FIXME not handling modifiers yet
    --      add this after extending __tostring so we can visualize
    if S.is_sequins(t) then t = t.data end -- handle sequins as input

    t = totable(t) -- convert a string to a table of chars

    -- walk the table to check for matching nested sequins
    for i=1,#t do
        if S.is_sequins(t[i]) and S.is_sequins(self.data[i]) then
            self.data[i]:settable(t[i])
        else
            self.data[i] = t[i] -- copy table piecemeal
        end
    end
    self.data[#t+1] = nil -- disregard any surplus data

    self.length = #t
    self.ix = wrap_index(self, self.ix)
end

function S.copy(og, cp)
    cp = cp or {}
    local og_type = type(og)
    local copy = {}
    if og_type == 'table' then
        if cp[og] then -- handle duplicate refs to an internal table
            copy = cp[og]
        else
            cp[og] = copy
            for og_k, og_v in next, og, nil do
                copy[S.copy(og_k, cp)] = S.copy(og_v, cp)
            end
            setmetatable(copy, S.copy(getmetatable(og), cp))
        end
    else -- literal value
        copy = og
    end
    return copy
end

S.metaix.copy = S.copy
S.metaix.settable = S.setdata -- use updated defn

rawset(S,__len,
    function(t)
        return t.length -- use memoized data length, aka #(t.data)
    end)

rawset(S,__tostring,
    function(t)
        -- data (will recursively call for other sequins)
        local st = {}
        for i=1,t.length do
            st[i] = tostring(t.data[i])
        end
        local s = string.format('s[%i]{%s}', t.ix, table.concat(st,','))

        -- modifiers
        -- TODO need to add metadata to modifiers so they can be introspected

        -- transforms
        -- TODO not sure what the structure is yet

        -- state
        -- s = string.format('%s<%s>', s, t.ix)

        return s
    end)

return setmetatable(S, S) -- use updated metamethods
