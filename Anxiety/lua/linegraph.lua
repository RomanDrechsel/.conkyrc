LineGraph = { Data = {}, Config = nil}

function LineGraph:new(config, width, height)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.Data = {}
    o.Width = width;
    o.Height = height;
    o.Lines = {}
    if config then
        o:setConfig(config)
    else
        o:setConfig(Config.LineGraph)
    end
    return o
end

function LineGraph:Draw(cr, x, y, data)
    if data == nil and #self.Data <= 0 then
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

    -- background
    if self.Config.Background then
        Draw:FillRect(cr, x, y, width, height, self.Config.Background)
    end

    -- grid
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

    -- add data to collection
    if data == nil then
        data = { ["line"] = 0 }
    elseif type(data) ~= "table" then
        data = { ["line"] = data }
    end

    for des, line_data in pairs(data) do
        if type(line_data) ~= "number" then
            line_data = tonumber(line_data) or 0
        end

        if self.Data[des] == nil then
            self.Data[des] = {}
        end
        table.insert(self.Data[des], line_data)
        while #self.Data[des] > historycount do
            table.remove(self.Data[des], 1)
        end

        if self.Lines[des] == nil then
            self.Lines[des] = self.Config.Graph
        end
    end

    -- draw line(s)
    for des, line_data in pairs(self.Data) do
        local dx = x + width
        local oy = y + height
        local points = { dx, oy }

        for i = #line_data, 1, -1 do
            local value = line_data[i]
            if value > self.Lines[des].Scale then
                value = self.Lines[des].Scale
            end
            table.insert(points, dx)
            table.insert(points, oy - math.floor(height * value / self.Lines[des].Scale))
            dx = dx - math.floor((width / (historycount - 1)) + 0.5)
            if dx < x then
                dx = x
            end
        end
        table.insert(points, dx)
        table.insert(points, oy)
        table.insert(points, x + width)
        table.insert(points, oy)
        if self.Lines[des] then
            if self.Lines[des].Background then
                Draw:FillPolygon(cr, points, self.Lines[des].Background)
            end
            if self.Lines[des].LineColor and self.Lines[des].LineWidth and self.Lines[des].LineWidth > 0 then
                table.remove(points, 1)
                table.remove(points, 1)
                table.remove(points, #points)
                table.remove(points, #points)
                if #self.Data >= historycount then
                    table.remove(points, #points)
                    table.remove(points, #points)
                end
                Draw:Polygon(cr, points, self.Lines[des].LineColor, self.Lines[des].LineWidth)
            end
        end

    end

    -- border
    if self.Config.Border and self.Config.Border.LineWidth then
        Draw:Rect(cr, x, y, width, height, self.Config.Border.LineWidth, self.Config.Border.Color)
    end

    return y + height
end

function LineGraph:setConfig(config)
    if config == nil then
        self.Config = {}
    else
        self.Config = table_copy(config)
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
    if self.Config.Graph.Scale == nil then
        self.Config.Graph.Scale = 100
    end
    if self.Config.Border == nil then
        self.Config.Border = {}
    end
    if self.Config.Grid == nil then
        self.Config.Grid = {}
    end
end
