RAM = { MemTotal = -1, MemUsed = -1, SwapTotal = -1, SwapUsed = -1 }

function RAM:new()
    if Config.LineGraph.Graph.LineColor and Config.LineGraph.Graph.LineWidth and Config.LineGraph.Graph.LineWidth > 0 then
        self.GraphLine = LineGraph:new(Config.LineGraph, nil, 70)
    end
    return self
end

function RAM:Update()
    local pipe = pipe("LANG=C && free -b")
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

function RAM:Display(cr, y)
    y = Draw:Header(cr, Locale.RAM, y)
    if self.GraphLine then
        y = self.GraphLine:Draw(cr, Config.MarginX, y, self.MemUsed / self.MemTotal * 100)
    end

    local usage = self:Usage()
    if usage and usage ~= "-" then
        y = Draw:Row(cr, y, Locale.RAM, Config.Text.Label, usage, Config.Text.Info, self:Percentage(), nil)
    end

    local swap = self:UsageSwap()
    if swap and swap ~= "-" then
        y = Draw:Row(cr, y, Locale.Swap, Config.Text.Label, swap, Config.Text.Info, self:PercentageSwap(), nil)
    end

    return y
end

function RAM:Usage()
    local used = nil
    local size = nil
    if self.MemUsed > 0 then
        used = format_bytes(self.MemUsed)
    end
    if used and self.MemTotal > 0 then
        size = format_bytes(self.MemTotal)
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
    if self.SwapTotal > 0 then
        size = format_bytes(self.SwapTotal)
    end
    if size and self.SwapUsed > 0 then
        used = format_bytes(self.SwapTotal)
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

RAM:new()
