local fu = require("functions")

local GPU = { Sensors = nil, Path = nil, DriverVersion = "", CardName = "" }
local last_min = -1

function GPU:new(sensors)
    self.Sensors = sensors;
    self.Path = "/sys/class/drm/"
    local card = fu:pipe("ls " .. self.Path .. " | grep -E '^card[0-9]+$'")
    if card == nil or string.len(card) == 0 then
        card = "card0"
    end

    self.Path = self.Path .. card .. "/device/"

    if fu:dir_exists(self.Path) then
        print("AMD-GPU Device found: " .. self.Path)
    else
        GPU.Path = nil
        print("No AMD-GPU Device found!")
    end

    return self
end

function GPU:Update()
    if last_min < os.time() - 60 then
        local glxinfo = fu:pipe("glxinfo | grep \"OpenGL version string\"")
        if glxinfo then
            local driver = glxinfo:match("OpenGL version string: %S+ %(.*%) (.+)") or glxinfo:match("OpenGL version string: %S+ (.+)")
            if driver then
                self.DriverVersion = fu:trim(driver)
            end
        end

        local card = fu:pipe("xrandr --listproviders | grep \"Provider 0\"")
        if card then
            local gpuName = card:match("name:(.-) @")
            if gpuName then
                self.CardName = gpuName
            end
        end

        last_min = os.time()
    end
end

function GPU:VRAM()
    if self.Path then
        local used = fu:pipe("cat " .. self.Path .. "mem_info_vram_used")
        local max =  fu:pipe("cat " .. self.Path .. "mem_info_vram_total")

        if used then
            used = fu:format_bytes(used) .. " GiB"
        else
            used = "?"
        end
        if max then
            max = fu:format_bytes(max) .. " GiB"
        else
            max = "?"
        end

        return used .. " / " .. max
    end
    return "-"
end

function GPU:Temp()
    if self.Sensors ~= nil and self.Sensors.Json ~= nil then
        local edge = self.Sensors.Json["amdgpu-pci-0300"]["edge"]["temp1_input"];
        local junction = self.Sensors.Json["amdgpu-pci-0300"]["junction"]["temp2_input"];

        if edge or junction then
            if edge then
                edge = fu:toInt(edge) .. "°C"
            end

            if junction then
                junction = fu:toInt(junction) .. "°C"
            end

            if edge and junction then
                return edge .. " / " .. junction
            elseif edge then
                return edge
            elseif junction then
                return junction
            end
        end
    end

    return ""
end

function GPU:Utilization()
    if self.Path then
        local curr = fu:pipe("grep -Pom 1 '\\d+:\\s\\K(\\d+)(?=.*\\*$)' " .. self.Path .. "pp_dpm_sclk")
        local max = fu:pipe("cat " .. self.Path .. "pp_dpm_sclk | tail -1 | cut -c4-7")

        if curr or max then
            if curr then
                curr = fu:toInt(curr) .. " MHz"
            else
                curr = "?"
            end
            if max then
                max = fu:toInt(max) .. " MHz"
            else
                max = "?"
            end

            return curr .. " / " .. max
        end
    end
    return "-"
end

function GPU:MemTemp()
    if self.Sensors ~= nil and self.Sensors.Json ~= nil then
        local temp = self.Sensors.Json["amdgpu-pci-0300"]["mem"]["temp3_input"];
        if temp then
            return fu:toInt(temp) .. "°C"
        end
    end

    return ""
end

function GPU:Fan()
    if self.Sensors ~= nil and self.Sensors.Json ~= nil then
        local curr = self.Sensors.Json["amdgpu-pci-0300"]["fan1"]["fan1_input"];
        local max =  self.Sensors.Json["amdgpu-pci-0300"]["fan1"]["fan1_max"];

        if curr then
            curr = fu:toInt(curr)
            local percent = "";
            if max then
                percent = fu:toInt(curr / max * 100)
                if percent then
                    percent = math.floor(percent + 0.5)
                    percent = " (" .. fu:toInt(curr / max * 100) .. "%)"
                end
            end
            return curr .. " RPM" .. percent
        end
    end

    return "-"
end

function GPU:Power()
    if self.Sensors ~= nil and self.Sensors.Json ~= nil then
        local curr = self.Sensors.Json["amdgpu-pci-0300"]["PPT"]["power1_average"];
        local max =  self.Sensors.Json["amdgpu-pci-0300"]["PPT"]["power1_cap"];

        if curr then
            curr = fu:toInt(curr)
            local percent = "";
            if max then
                percent = fu:toInt(curr / max * 100)
                if percent then
                    percent = math.floor(percent + 0.5)
                    percent = " (" .. fu:toInt(curr / max * 100) .. "%)"
                end
            end
            return curr .. " W" .. percent
        end
    end
    return "-"
end

function GPU:Card()
    return self.CardName
end

function GPU:Driver()
    return self.DriverVersion
end

function GPU:Graph()
    if self.Path then
        return conky_parse("${execgraph \"cat " .. self.Path .. "/gpu_busy_percent\" 33CC33 CC5933 -t }")
    end
    return ""
end

return GPU