CPU = { CPUName = "", StatsAvail = false, GraphMain = nil }

function CPU:new()
    self.CPUName = pipe("grep model /proc/cpuinfo | cut -d : -f2 | tail -1 | sed 's/\\s//'")
    self._json = nil

    if package_installed("mpstat") == false then
        print("Package \"mpstat\" not installed!")
        print("run \"sudo apt install sysstat\"")
    else
        self.StatsAvail = true
        if Config.PieGraph.Graph.Color then
            local configMainGraph = table_copy(Config.PieGraph)
            configMainGraph.Graph.Radius = 35
            self.GraphMain = PieGraph:new(configMainGraph, 80, 130)
       
            self._configSmallGraph = table_copy(Config.PieGraph)
            self._configSmallGraph.Graph.BarWidthPercent = 75
            self._configSmallGraph.Graph.Label.FontSize = 10
            self._configSmallGraph.PaddingPercent = 20
        end
        if Config.LineGraph.Graph.LineColor and Config.LineGraph.Graph.LineWidth and Config.LineGraph.Graph.LineWidth > 0 then
            self.GraphLine = LineGraph:new(Config.LineGraph, nil, 30)
        end
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

    if self.GraphMain and self._json then
        -- Background
        local num_cpu = #self._json - 1
        local rx = Config.MarginX + self.GraphMain.Width + 10

        local height = math.ceil((num_cpu * 35) / (conky_window.width - rx - Config.MarginX)) * 45
        if height < self.GraphMain.Height then
            height = self.GraphMain.Height
        end
        Draw:FillRect(cr, Config.MarginX, y, conky_window.width - (2 * Config.MarginX), height, "#00000060")

        -- main cpu
        local util = self:Utilization()
        if util > 0 then
            self.GraphMain:Draw(cr, Config.MarginX, y, util, { util .. "%", self:Temp() })
        end

        if self.GraphsSmall == nil then
            self.GraphsSmall = {}
        end

        local dx = rx
        local dy = y

        if self._configSmallGraph then
            local i = 1;

            for _,line in ipairs(self._json) do
                if line["cpu"] ~= "all" then
                    if self.GraphsSmall[i] == nil then
                        table.insert(self.GraphsSmall, PieGraph:new(self._configSmallGraph, 28, 38))
                    end

                    local usage = tonumber(line["usage"])
                    if usage >= 100 then
                        usage = toInt(usage)
                    elseif usage >= 10 then
                        usage = tonumber(string.format("%.1f", usage))
                    end

                    self.GraphsSmall[i]:Draw(cr, dx, dy, line["usage"], usage .. "%")
                    dx = dx + self.GraphsSmall[i].Width + 7
                    if dx > conky_window.width - Config.MarginX - self.GraphsSmall[i].Width then
                        dx = rx
                        dy = dy + self.GraphsSmall[i].Height + 7
                    end

                    i = i + 1
                end
            end
            if #self.GraphsSmall > 0 then
                dy = dy + self.GraphsSmall[1].Height + 7
            end
        end

        y = dy;

        if self.GraphLine then
            y = self.GraphLine:Draw(cr, Config.MarginX, y, util)
        end

    end

    return y
end

function CPU:Temp()
    if Sensors and Sensors.Json then
        local temp = Sensors.Json["coretemp-isa-0000"]["Package id 0"]["temp1_input"];
        if temp then
            return toInt(temp) .. "°C"
        end
    end
    return ""
end

function CPU:Update()
    self.Utilizations = nil
    if self.StatsAvail then
        os.execute(pwd .. "../bash/mpstat.sh \"" .. CacheDir .. "mpstat\" &")
        local mpstat = read_cache("mpstat")
        if mpstat ~= nil then
            local success, _json = pcall(json.parse, mpstat)
            if success and _json and _json ~= json.null then
                self._json = _json;
            end
        end
    end
end

function CPU:Utilization()
    if self._json ~= nil and type(self._json) == 'table' then
        for _,line in ipairs(self._json) do
            if line["cpu"] == "all" then
                return tonumber(line["usage"])
            end
        end
    end
    return tonumber(conky_parse("${cpu cpu" .. cpu .. "}"))
end

CPU:new()