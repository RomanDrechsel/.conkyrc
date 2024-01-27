CPU = { CPUName = "", StatsAvail = false, Graph = nil }

function CPU:new()
    self.CPUName = pipe("grep model /proc/cpuinfo | cut -d : -f2 | tail -1 | sed 's/\\s//'")

    if package_installed("mpstat") == false then
        print("Package \"mpstat\" not installed!")
        print("run \"sudo dnf install mpstat\"")
    else
        self.StatsAvail = true
        local config = table.pack(table.unpack(Config.PieGraph))
        if config.Graph == nil then
            config.Graph = {}
        end
        config.Graph.Radius = 35
        self.Graph = PieGraph:new(nil, 80)
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

    if self.Graph then
        local util = self:Utilization()
        self.Graph:Draw(cr, Config.MarginX, y, util, util .. "%")
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

function CPU:Utilization()
    if self.StatsAvail then
        local stat = pipe("mpstat | tail -1 | awk '{print $NF}'")
        if stat then
            local float = tonumber(stat:match("[%d,]+%.?%d*")) or 0
            if float then
                return tonumber(100.0 - float + math.random(10, 50))
            end
        end
    end
    return -1
end














function CPU:Usage()
    if self.StatsAvail then
        local stat = pipe("mpstat | tail -1 | awk '{print $NF}'")
        if stat then
            local float = tonumber(stat:match("[%d,]+%.?%d*")) or 0
            if float then
                return (100.0 - float) .. "%"
            end
        end
    end
    return ""
end

function CPU:Bar()
    return "${voffset 1}${cpubar cpu0 10,0}"
end






CPU:new()