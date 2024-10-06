BarGraph = { Config = nil }

function BarGraph:new(config, height)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    if config then
        o:setConfig(config)
    else
        o:setConfig(Config.LineGraph)
    end

    if height then
        o.Height = height;
    else
        o.Height = o.Config.DefaultHeight
    end

    return o
end

function BarGraph:Draw(cr, x, y, data)
    if data == nil or self.Height == nil or self.Height < 0 then
        data = 0
    end
    if type(data) ~= "number" then
        data = tonumber(data) or 0
    end

    width = conky_window.width - x - Config.MarginX
    if width <= 0 or self.Height == nil or self.Height <= 0 then
        return
    end

    -- background
    if self.Config.Background then
        Draw:FillRect(cr, x, y, width, self.Height, self.Config.Background)
    end

    -- grid
    if self.Config.Grid.LineWidth and self.Config.Grid.Color then
        Draw:Color(cr, self.Config.Grid.Color)
        if self.Config.Grid.PartsX then
            local gw = math.ceil(width / self.Config.Grid.PartsX)
            local gx = x + gw
            while gx < x + width do
                Draw:Line(cr, gx, y, gx, y + self.Height, self.Config.Grid.LineWidth)
                gx = gx + gw
            end
        end
    end

    -- bar
    if data > 0 then
        local barwidth = data / self.Config.Graph.Scale * width
        Draw:FillRect(cr, x, y, barwidth, self.Height, self.Config.Graph.Color)
    end

    -- border
    if self.Config.Border and self.Config.Border.LineWidth then
        Draw:Rect(cr, x, y, width, self.Height, self.Config.Border.LineWidth, self.Config.Border.Color)
    end

    return y + self.Height
end

function BarGraph:setConfig(config)
    if config == nil then
        self.Config = {}
    else
        self.Config = table_copy(config)
    end
end
