local fu = require("functions")

local Disk = { Sensors = nil, Used = -1, Size = -1, Percent = -1 }

function Disk:new(sensors)
    self.Sensors = sensors;
    self:Update();

    return self
end

function Disk:Temp()
    if self.Sensors ~= nil and self.Sensors.Json ~= nil then
        local curr = self.Sensors.Json["nvme-pci-0400"]["Composite"]["temp1_input"];
        if curr then
            return fu:toInt(curr) .. "°C"
        end
    end
    return "";
end

function Disk:Usage()
    
end

function Disk:Update()
    local disk = fu:pipe("df --total --sync | grep -E ' /$'")
    if disk then
        _, _, _, size, used, _, percent, _ = disk:match("(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)")
        if size then
            self.Size = fu:toInt(size)
        else
            self.Size = -1
        end
        if used then
            self.Used = fu:toInt(used)
        else
            self.Used = -1
        end
        if percent then
            self.Percent = fu:toInt(percent)
        else
            self.Percent = -1
        end
    end
end

return Disk