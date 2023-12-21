local fu = require("functions")
local json = require("json")

local Sensors = { Init = false, Json = nil }

function Sensors:new()
    if fu:package_installed("sensors") == false then
        print("Package \"sensors\" not installed!")
        print("run \"sudo apt-get install lm_sensors\"")
    else
        self.Init = true
    end

    return self
end

function Sensors:Update()
    local sensors = fu:pipe("sensors -j")
    if fu:isNotEmpty(sensors) then
        self.Json = nil
    end

    self.Json = json.parse(sensors)
    if self.Json == json.null then
        self.Json = nil
    end
end

return Sensors