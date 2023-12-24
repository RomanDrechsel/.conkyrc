local fu = require("functions")

local CPU = { Sensors = nil, CPUName = "", StatsAvail = false }

function CPU:new(sensors)
    self.Sensors = sensors;
    self.CPUName = fu:pipe("grep model /proc/cpuinfo | cut -d : -f2 | tail -1 | sed 's/\\s//'")

    if fu:package_installed("mpstat") == false then
        print("Package \"mpstat\" not installed!")
        print("run \"sudo apt-get install mpstat\"")
    else
        self.StatsAvail = true
    end

    return self
end

function CPU:Temp()
    if self.Sensors ~= nil and self.Sensors.Json ~= nil then
        local temp = self.Sensors.Json["coretemp-isa-0000"]["Package id 0"]["temp1_input"];
        if temp then
            return fu:toInt(temp) .. "°C"
        end
    end

    return ""
end

function CPU:Usage()
    if self.StatsAvail then
        local stat = fu:pipe("mpstat | tail -1 | awk '{print $NF}'")
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

return CPU