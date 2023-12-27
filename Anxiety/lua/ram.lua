RAM = { MemTotal = -1, MemUsed = -1, SwapTotal = -1, SwapUsed = -1 }

function RAM:Update()
    local pipe = pipe("free -b")
    if pipe then
        local mem_total, mem_used, _, _, _, _ = pipe:match("Mem:%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
        local swap_total, swap_used, _ = pipe:match("Swap:%s+(%d+)%s+(%d+)%s+(%d+)")

        if mem_total then
            self.MemTotal = tonumber(mem_total)
        end
        if mem_used then
            self.MemUsed = tonumber(mem_used)
        end
        if swap_total then
            self.SwapTotal = tonumber(swap_total)
        end
        if swap_used then
            self.SwapUsed = tonumber(swap_used)
        end
    end
end

function RAM:Usage()
    local used = nil
    local size = nil
    if self.MemUsed >= 0 then
        used = format_bytes(self.MemUsed) .. " GiB"
    end
    if self.MemTotal > 0 then
        size = format_bytes(self.MemTotal) .. " GiB"
    end

    if used and size then
        return used .. " / " .. size
    elseif used then
        return used
    elseif size then
        return size
    end
    return "-"
end

function RAM:Percentage()
    if self.MemTotal > 0 and self.MemUsed >= 0 then
        return string.format("%.2f", self.MemUsed / self.MemTotal * 100) .. "%"
    end
    return ""
end

function RAM:UsageSwap()
    local used = nil
    local size = nil
    if self.SwapUsed >= 0 then
        used = format_bytes(self.SwapUsed) .. " GiB"
    end
    if self.SwapTotal > 0 then
        size = format_bytes(self.SwapTotal) .. " GiB"
    end

    if used and size then
        return used .. " / " .. size
    elseif used then
        return used
    elseif size then
        return size
    end
    return "-"
end

function RAM:PercentageSwap()
    if self.SwapTotal > 0 and self.SwapUsed >= 0 then
        return string.format("%.2f", self.SwapUsed / self.SwapTotal * 100) .. "%"
    end
    return ""
end