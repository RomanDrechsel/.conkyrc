Disk = { Sensors = nil, Used = -1, Size = -1, Percent = "" }

function Disk:Temp()
    if Sensors and Sensors.Json  then
        local curr = Sensors.Json["nvme-pci-0400"]["Composite"]["temp1_input"];
        if curr then
            return toInt(curr) .. "°C"
        end
    end
    return "";
end

function Disk:Usage()
    if self.Used > 0 then
        if self.Size > 0 then
            return format_bytes(self.Used) .. " GiB / " .. format_bytes(self.Size) .. " GiB"
        else
            return format_bytes(self.Used) .. " GiB"
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