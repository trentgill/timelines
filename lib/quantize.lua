function quantize( volt, scale, divs, range )
    -- defaults
    chrom = {0,1,2,3,4,5,6,7,8,9,10,11}
    if scale == nil then scale = chrom end
    local notes = #scale
    if notes == 0 then
        scale = chrom
        notes = #scale
    end
    divs,range = divs  or 12
               , range or 1.0

    -- separate note & octave
    local wrap = 0
    if type(divs) == 'string' then -- assume just intonation
    else
        while volt > range do
            
        end
    end

    -- calc index into table
    local ix = 1+math.floor(volt/range * #scale)

    -- scale to voltage
    local v = 0
    if type(divs) == 'string' then -- assume just intonation
        v = math.log(scale[ix]) / math.log(2)
    else
        v = scale[ix] / divs
    end

    return v * range
    -- reapply octave
end
