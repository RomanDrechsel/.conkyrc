LineGraph = { Data = {}, Width = 0, Height = 0, Config = nil}

function LineGraph:new(config, width, height)
    self.Data = {}
    self.Width = width;
    self.Height = height;
    if config then
        self:setConfig(config)
    else
        self:setConfig(Config.LineGraph)
    end
    return self
end

function LineGraph:Draw(cr, x, y, data)
    if #self.Data <= 0 and data == nil then
        return
    end

    local width = self.Width
    if width == nil then
        width = conky_window.width - x - Config.MarginX
    end

    local height = self.Height
    if height == nil or height <= 0 then
        height = self.Config.DefaultHeight
    end

    if width == nil or width <= 0 or height == nil or height <= 0 then
        return
    end

    local historycount = self.Config.HistoryCount
    if historycount > width then
        historycount = width
        if self.Config.Border.LineWidth then
            historycount = historycount - (2 * self.Config.Border.LineWidth)
        end
    end

    if self.Config.Background then
        Draw:FillRect(cr, x, y, width, height, self.Config.Background)
    end

    if self.Config.Grid.LineWidth and self.Config.Grid.Color then
        Draw:Color(cr, self.Config.Grid.Color)
        if self.Config.Grid.PartsX then
            local gw = math.ceil(width / self.Config.Grid.PartsX)
            local gx = x + gw
            while gx < x + width do
                Draw:Line(cr, gx, y, gx, y + height, self.Config.Grid.LineWidth)
                gx = gx + gw
            end
        end
        if self.Config.Grid.PartsY then
            local gh = math.ceil(height / self.Config.Grid.PartsY)
            local gy = y + gh
            while gy < y + height do
                Draw:Line(cr, x, gy, x + width, gy, self.Config.Grid.LineWidth)
                gy = gy + gh
            end
        end
    end

    if data == nil or data < 0 then
        data = 0
    end

    table.insert(self.Data, data)
    while #self.Data > historycount do
        table.remove(self.Data, 1)
    end

    local dx = x + width
    local oy = y + height
    local points = { dx, oy }

    for i = #self.Data, 1, -1 do
        local value = self.Data[i]
        if value > self.Config.Graph.ScaleX then
            value = self.Config.Graph.ScaleX
        end
        table.insert(points, dx)
        table.insert(points, oy - math.floor(height * value / self.Config.Graph.ScaleX))
        dx = dx - math.floor((width / (historycount - 1)) + 0.5)
        if dx < x then
            dx = x
        end
    end
    table.insert(points, dx)
    table.insert(points, oy)
    table.insert(points, x + width)
    table.insert(points, oy)

    if self.Config.Graph and self.Config.Graph.LineColor then
        Draw:FillPolygon(cr, points, self.Config.Graph.Background)
        if self.Config.Border and self.Config.Border.LineWidth and self.Config.Border.LineWidth > 0 then
            table.remove(points, 1)
            table.remove(points, 1)
            table.remove(points, #points)
            table.remove(points, #points)
            if #self.Data >= historycount then
                table.remove(points, #points)
                table.remove(points, #points)
            end
        end
        Draw:Polygon(cr, points, self.Config.Graph.LineColor, self.Config.Graph.LineWidth)
    end

    if self.Config.Border and self.Config.Border.LineWidth then
        Draw:Rect(cr, x, y, width, height, self.Config.Border.LineWidth, self.Config.Border.Color)
    end

    return y + height
end

function LineGraph:setConfig(config)
    if config == nil then
        self.Config = {}
    else
        self.Config = config
    end

    if self.Config.HistoryCount == nil or self.Config.HistoryCount <= 0 then
        self.Config.HistoryCount = 10
    end
    if self.Config.HistoryCount > 120 then
        self.Config.HistoryCount = 120
    end

    if self.Config.Graph == nil then
        self.Config.Graph = {}
    end
    if self.Config.Graph.ScaleX == nil then
        self.Config.Graph.ScaleX = 100
    end
    if self.Config.Border == nil then
        self.Config.Border = {}
    end
    if self.Config.Grid == nil then
        self.Config.Grid = {}
    end
end
