-- expect note_list as a set of 12Tet numbers
-- output as a voltage-scaled CV
-- TOOD ji support (as 'out_oct' param?)
function quantizer(note_list, in_oct, out_oct)
    in_oct, out_oct = in_oct or 12, out_oct or 1
    local len = #note_list
    local mul = out_oct/in_oct
    local normal = len/in_oct

    -- this function will take a 12Tet note num, and output a quantized note/voltage + octave
    return function(n)
        -- quantize n to the closured params above
        n = n + 0.5 -- centre the window. TODO in_oct sensitive
        local rem = n % in_oct 
        local oct = n - rem -- increments in steps of in_oct 

        return mul*note_list[math.floor(rem * normal) + 1], mul*oct
    end
end

-- example usage
--[[
-- quantize a 12TET style note into a voltage output
q1 = quantizer{0,2,4,6,7,9,11}
ii.wsyn.play_note(q1(math.random()*12), 2) -- play a random note in the scale

local n, o = q1(math.random()*12*3) -- bigger range, save octave too
ii.wsyn.play_note(n+o, 2) -- play a random note in scale, over 3 octaves

s2 = quantizer{0,12,4,2,-5,6,11} -- the octave can be rearranged & extend the input range
counter = 1
-- this timeline will play through 3 octaves of sequence
tl.loop{2, function() ii.wsyn.play_note(q1(counter % 36), 2); counter = counter + 1 end}

]]
