PieGraph = { Config = nil}

function PieGraph:new(config, width, height)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.Data = {}
    if config then
        o:setConfig(config)
    else
        o:setConfig(Config.PieGraph)
    end

    if width then
        o.Width = width
    else
        o.Width = o.Config.DefaultSize
    end
    if height then
        o.Height = height
    else
        o.Height = o.Width
    end

    maxsize = o.Width
    if o.Height and  o.Height < maxsize then
        maxsize = o.Height
    end

    if maxsize and maxsize > 0 then
        maxsize = maxsize * (100 - o.Config.PaddingPercent) / 100

        o.BarWidth = maxsize / 2 * o.Config.Graph.BarWidthPercent / 100
        o.Radius = (maxsize / 2)
    end

    return o
end

function PieGraph:Draw(cr, x, y, data, label)
    if self.Width == nil or self.Width <= 0 then
        return
    end

    if type(data) ~= "number" then
        data = tonumber(data) or 0
    end

    local center_x = x + (self.Width / 2)
    local center_y = y + (self.Width / 2)

    if self.Config.Graph.EmptyColor then
        Draw:Circle(cr, center_x, center_y, self.Radius - (self.BarWidth / 2), self.Config.Graph.EmptyColor, self.BarWidth)
    end

    if data > self.Config.Graph.Scale then
        data = self.Config.Graph.Scale
    end

    local angle_zero = math.rad(30)
    local deg = math.rad(3.6 * data)

    -- main bar
    if deg > 0 then
        Draw:Color(cr, self.Config.Graph.Color)
        Draw:Arc(cr, center_x, center_y, self.Radius - (self.BarWidth / 2), self.Config.Graph.Color, self.BarWidth, angle_zero, angle_zero - deg)
    end

    -- border
    if self.Config.Border.LineWidth then
        Draw:Color(cr, self.Config.Border.Color)
        Draw:Circle(cr, center_x, center_y, self.Radius, nil, self.Config.Border.LineWidth)
        Draw:Circle(cr, center_x, center_y, self.Radius - self.BarWidth, nil, self.Config.Border.LineWidth)
    end

    -- label
    if label ~= nil then
        if type(label) ~= "table" then
            label = { label }
        end

        Draw:Font(cr, self.Config.Graph.Label)
        for i,line in ipairs(label) do
            Draw:PointText(cr, line, center_x, center_y + (self.Radius * 1.4) + (getFontHeight(cr) * (i - 1)))
        end
    end

    return y + self.Height
end

function PieGraph:setConfig(config)
    if config == nil then
        self.Config = {}
    else
        self.Config = table.copy(config)
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
    if self.Config.PaddingPercent == nil or self.Config.PaddingPercent > 100 or self.Config.PaddingPercent <= 0 then
        self.Config.PaddingPercent = 0
    end
    if self.Config.Graph.BarWidthPercent == nil or self.Config.Graph.BarWidthPercent > 100 or self.Config.Graph.BarWidthPercent <= 0 then
        self.Config.Graph.BarWidthPercent = 50
    end

    if self.Config.Border == nil then
        self.Config.Border = {}
    end
    if self.Config.Grid == nil then
        self.Config.Grid = {}
    end
end