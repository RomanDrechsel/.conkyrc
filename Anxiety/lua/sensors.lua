Sensors = {}

function Sensors:new()
    if package_installed("sensors") == false then
        print("Package \"sensors\" not installed!")
        print("run \"sudo apt install lm-sensors\"")
    else
        self.Init = true
    end

    return self
end

function Sensors:Update()
    local sensors = pipe("sensors -j")
    if isEmpty(sensors) then
        self.Json = nil
    end

    self.Json = json.parse(sensors)
    if self.Json == json.null then
        self.Json = nil
    end
end