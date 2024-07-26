Sensors = {}
function Sensors:new()
    if package_installed("sensors") == false then
        print("Package \"sensors\" not installed!")
        print("run \"sudo apt install lm-sensors\"")
    else
        print("Sensors init")
        self.Init = true
    end

    return self
end

function Sensors:Update()
    if self.Init then
        local sensors = pipe("sensors -j")
        if isEmpty(sensors) then
            self.Json = nil
        else
            local success, _json = pcall(json.parse, sensors)
            if success and _json and _json ~= json.null then
                self.Json = _json
            else
                self.Json = nil
            end
        end
    else
        self.Json = nil
    end
end

Sensors = Sensors:new()
