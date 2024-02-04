Disk = { Sensors = nil, Used = -1, Size = -1, Percent = "" }

function Disk:Display(cr, y)
    y = Draw:Header(cr, Locale.Disk, y)

    if Config.Partitions then
        if self.Graphs == nil then
            self.Graphs = {}
        end

        local i = 1
        Draw:Font(cr, Config.Text.Label)
        local bar_x = textWidth(cr, Config.Partitions) + Config.MarginX + 15
        for _, part in ipairs(Config.Partitions) do
            if self._df[part] then
                local usage = self:Usage(self._df[part]["used"], self._df[part]["size"])
                if usage and usage ~= "" then
                    if self.Graphs[i] == nil then
                        table.insert(self.Graphs, BarGraph:new(Config.BarGraph))
                    end

                    self.Graphs[i]:Draw(cr, bar_x, y + 6, self._df[part]["percent"])

                    Draw:Font(cr, Config.Text.Label)
                    _, y = Draw:LeftText(cr, part, y)                    
                    y = Draw:Row(cr, y, usage, Config.Text.Info, nil, nil, self._df[part]["percent"] .. "%", nil)
                    i = i + 1
                end
            end
        end
    end

    return y
end

function Disk:Temp()
    if Sensors and Sensors.Json  then
        local curr = Sensors.Json["nvme-pci-0400"]["Composite"]["temp1_input"];
        if curr then
            return toInt(curr) .. "°C"
        end
    end
    return "";
end

function Disk:Usage(used, size)
    if used == nil then
        used = self.Used
    end
    if size == nil then
        size = self.Size
    end

    if used > 0 then
        if size > 0 then
            return format_bytes(used) .. " GiB / " .. format_bytes(size) .. " GiB"
        else
            return format_bytes(used) .. " GiB"
        end
    end

    return ""
end

function Disk:Percentage()
    if self.Percent then
        return self.Percent
    end

    return ""
end

function Disk:Update()
    if Config.Partitions then
        if type(Config.Partitions) ~= "table" then
            Config.Partitions = { Config.Partitions }
        end

        self._df = {}
        local disk = pipe("df -P --sync")
        if disk then
            local lines = split(disk)
            for _, line in ipairs(lines) do
                local _, size, used, _, _, mount = line:match("(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)")
                if in_array(Config.Partitions, mount) then
                    local percent = tonumber(string.format("%.2f", used / size * 100))
                    self._df[mount] = { size = toInt(size) * 1024, used = toInt(used) * 1024, percent = percent }
                end
            end
        end
    end
    
    local disk = pipe("df -P --sync | grep -E ' /$'")
    if disk then
        local _, size, used, _, percent, _ = disk:match("(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)")

        if size then
            self.Size = toInt(size) * 1024
        else
            self.Size = -1
        end
        if used then
            self.Used = toInt(used) * 1024
        else
            self.Used = -1
        end
        if percent then
            self.Percent = percent
        else
            self.Percent = ""
        end
    end
end