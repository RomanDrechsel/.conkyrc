Disk = { Sensors = nil, Used = -1, Size = -1, Percent = "" }

function Disk:new()
    self.Partitions = {
        "/",
        "/mnt/zusatz",
        "/mnt/arbeit"
    }
    print("Disk Init")
    return self
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

function Disk:Usage(part)
    if self._df and self._df[part] then
        local used = self._df[part]["used"]
        local size = self._df[part]["size"]
        if used > 0 then
            if size > 0 then
                return format_bytes(used) .. " / " .. format_bytes(size)
            else
                return format_bytes(used)
            end
        end
    end
    return nil;
end

function Disk:Percent(part)
    if self._df and self._df[part] then
        return toInt(self._df[part]["percent"])
    else
        return nil
    end
end

function Disk:Update()
    if self.Partitions then
        if type(self.Partitions) ~= "table" then
            self.Partitions = { self.Partitions }
        end

        self._df = {}
        local disk = pipe("df -P --sync")
        if disk then
            local lines = split(disk)
            for _, line in ipairs(lines) do
                local _, size, used, _, _, mount = line:match("(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)")
                if in_array(self.Partitions, mount) then
                    local percent = tonumber(string.format("%.2f", used / size * 100))
                    self._df[mount] = { size = toInt(size) * 1024, used = toInt(used) * 1024, percent = percent }
                end
            end
        end
    end
end

Disk = Disk:new()
