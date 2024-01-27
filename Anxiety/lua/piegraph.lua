PieGraph = { Size = nil, Config = nil}

function PieGraph:new(config, size)
    self.Data = {}
    if config then
        self:setConfig(config)
    else
        self:setConfig(Config.PieGraph)
    end

    if size == nil then
        self.Size = self.Config.DefaultSize
    else
        self.Size = size;
    end

    if self.Size and self.Size > 0 then
       self.Radius = self.Size / 2 * (100 - self.Config.Graph.PaddingPercent) / 100
       self.BarWidth = self.Radius * (self.Config.Graph.BarWidthPercent / 100)
    end

    return self
end

function PieGraph:Draw(cr, x, y, data, label)
    if self.Size == nil or self.Size <= 0 then
        return
    end

    if self.Config.Background then
        Draw:FillRect(cr, x, y, self.Size, self.Size, self.Config.Background)
    end

    local cx = x + self.Size / 2
    local cy = y + self.Size / 2

    if self.Config.Graph.EmptyColor then
        Draw:Circle(cr, cx, cy, self.Radius - (self.BarWidth / 2), self.Config.Graph.EmptyColor, self.BarWidth)
    end

    if data > self.Config.Graph.Scale then
        data = self.Config.Graph.Scale
    end

    local angle_zero = math.rad(90)
    --local deg = math.rad(data / self.Config.Graph.Scale * 360)
    local deg = math.rad(30)

    if deg > 0 then
        Draw:Color(cr, self.Config.Graph.Color)
        Draw:Arc(cr, cx, cy, self.Radius - (self.BarWidth / 2), self.Config.Graph.Color, self.BarWidth, angle_zero, angle_zero - deg)
    end


    if self.Config.Border.LineWidth then
        Draw:Color(cr, self.Config.Border.Color)
        Draw:Circle(cr, cx, cy, self.Radius, nil, self.Config.Border.LineWidth)
        Draw:Circle(cr, cx, cy, self.Radius - self.BarWidth, nil, self.Config.Border.LineWidth)
    end
end

function PieGraph:setConfig(config)
    if config == nil then
        self.Config = {}
    else
        self.Config = config
    end

    if self.Config.Graph == nil then
        self.Config.Graph = {}
    end
    if self.Config.Graph.Scale == nil then
        self.Config.Graph.Scale = 100
    end
    if self.Config.Graph.Color == nil then
        self.Config.Graph.Color = "#00FF00"
    end
    if self.Config.Graph.PaddingPercent == nil or self.Config.Graph.PaddingPercent > 100 or self.Config.Graph.PaddingPercent <= 0 then
        self.Config.Graph.PaddingPercent = 100
    end
    if self.Config.Graph.BarWidthPercent == nil or self.Config.Graph.BarWidthPercent > 100 or self.Config.Graph.BarWidthPercent <= 0 then
        self.Config.Graph.BarWidthPercent = 20
    end

    if self.Config.Border == nil then
        self.Config.Border = {}
    end
    if self.Config.Grid == nil then
        self.Config.Grid = {}
    end
end