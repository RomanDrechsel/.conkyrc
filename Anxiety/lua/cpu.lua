CPU = { CPUName = "", GraphMain = nil, CPUCount = 1 }

function CPU:new()
    self.CPUName = pipe("grep model /proc/cpuinfo | cut -d : -f2 | tail -1 | sed 's/\\s//'")
    self.CPUCount = tonumber(pipe("lscpu | grep '^CPU(s):' | awk '{print $2}'"))

    if Config.PieGraph.Graph.Color then
        local configMainGraph = table_copy(Config.PieGraph)
        configMainGraph.Graph.Radius = 30
        self.GraphMain = PieGraph:new(configMainGraph, 90, 170)
        self._configSmallGraph = table_copy(Config.PieGraph)
        self._configSmallGraph.Graph.BarWidthPercent = 75
        self._configSmallGraph.Graph.Label.FontSize = 12
        self._configSmallGraph.PaddingPercent = 20
    end
    if Config.LineGraph.Graph.LineColor and Config.LineGraph.Graph.LineWidth and Config.LineGraph.Graph.LineWidth > 0 then
        self.GraphLine = LineGraph:new(Config.LineGraph, nil, 70)
    end

    return self
end

function CPU:Display(cr, y)
    y = Draw:Header(cr, Locale.CPU, y)
    if Config.Text then
        Draw:Font(cr, Config.Text.Special)
    end

    _, y = Draw:LeftText(cr, self.CPUName, y)

    y = y + (Config.Padding * 2)

    if self.GraphMain then
        -- Background
        local smallGraphWidth = 25
        local smallGraphHeight = 40
        local rx = Config.MarginX + self.GraphMain.Width + 10
        local cpuRows = math.ceil((self.CPUCount * smallGraphWidth) / (conky_window.width - rx - Config.MarginX))

        local height = cpuRows * (smallGraphHeight + 7)
        if height < self.GraphMain.Height then
            height = self.GraphMain.Height
        end
        Draw:FillRect(cr, Config.MarginX, y, conky_window.width - (2 * Config.MarginX), height, "#00000060")

        -- main cpu
        local util = self:Utilization(0)
        self.GraphMain:Draw(cr, Config.MarginX, y, util, { util .. "%", self:Temp() })

        if self.GraphsSmall == nil then
            self.GraphsSmall = {}
        end

        if self._configSmallGraph and self.CPUCount > 1 then
            local dx = rx
            local dy = y

            for i = 1, self.CPUCount, 1 do
                usage = self:Utilization(i)
                if usage then
                    if self.GraphsSmall[i] == nil then
                        table.insert(self.GraphsSmall, PieGraph:new(self._configSmallGraph, smallGraphWidth, smallGraphHeight))
                    end
                    self.GraphsSmall[i]:Draw(cr, dx, dy, usage, usage .. "%")
                    dx = dx + self.GraphsSmall[i].Width + 7
                    if dx > conky_window.width - Config.MarginX - self.GraphsSmall[i].Width then
                        dx = rx
                        dy = dy + self.GraphsSmall[i].Height + 7
                    end
                end
            end
            if #self.GraphsSmall > 0 then
                dy = dy + self.GraphsSmall[1].Height + 7
            end
        end

        y = y + height

        if self.GraphLine then
            y = self.GraphLine:Draw(cr, Config.MarginX, y, util)
        end
    end

    return y
end

function CPU:Temp()
    if Sensors and Sensors.Json then
        local temp = Sensors.Json["k10temp-pci-00c3"]["Tctl"]["temp1_input"];
        if temp then
            return toInt(temp) .. "°C"
        end
    end
    return ""
end

function CPU:Utilization(cpu)
    return tonumber(conky_parse("${cpu cpu" .. cpu .. "}"))
end

CPU:new()
