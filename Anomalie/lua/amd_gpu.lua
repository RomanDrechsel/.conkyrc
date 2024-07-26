local path = "/sys/class/drm/"
local card = pipe("ls " .. path .. " | grep -E '^card[0-9]+$'")
if card == nil or string.len(card) == 0 then
    card = "card0"
end
path = path .. card .. "/device/"

function conky_getGpuLoad()
    if path then
        local gpu = pipe("cat " .. path .. "/gpu_busy_percent")
        return gpu
    else
        return 0
    end
end

function conky_getGpuUtil()
    if path then
        local curr = pipe("grep -Pom 1 '\\d+:\\s\\K(\\d+)(?=.*\\*$)' " .. path .. "pp_dpm_sclk")
        local max = pipe("cat " .. path .. "pp_dpm_sclk | tail -1 | cut -c4-7")

        if curr or max then
            if curr then
                curr = toInt(curr) .. " MHz"
            else
                curr = "?"
            end
            if max then
                max = toInt(max) .. " MHz"
            else
                max = "?"
            end
            return curr .. " / " .. max
        end
    else
        return ""
    end
end

function conky_getGpuVRAM()
    if path then
        local used = pipe("cat " .. path .. "mem_info_vram_used")
        local max =  pipe("cat " .. path .. "mem_info_vram_total")

        if used then
            used = format_bytes(used)
        else
            used = "?"
        end
        if max then
            max = format_bytes(max)
        else
            max = "?"
        end

        return used .. " / " .. max
    end
    return ""
end

function conky_getGpuTemp()
    if Sensors and Sensors.Json then
        local edge = Sensors.Json["amdgpu-pci-0300"]["edge"]["temp1_input"];
        local junction = Sensors.Json["amdgpu-pci-0300"]["junction"]["temp2_input"];

        if edge or junction then
            if edge then
                edge = toInt(edge) .. "°C"
            end

            if junction then
                junction = toInt(junction) .. "°C"
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

function conky_getGpuFan()
    if Sensors and Sensors.Json then
        local curr = Sensors.Json["amdgpu-pci-0300"]["fan1"]["fan1_input"];
        local max =  Sensors.Json["amdgpu-pci-0300"]["fan1"]["fan1_max"];

        if curr then
            curr = toInt(curr)
            local percent = "";
            if max then
                percent = toInt(curr / max * 100)
                if percent then
                    percent = math.floor(percent + 0.5)
                    percent = " (" .. toInt(curr / max * 100) .. "%)"
                end
            end
            return curr .. " RPM" .. percent
        end
    end

    return ""
end

function conky_getGpuPower()
    if Sensors and Sensors.Json then
        local curr = Sensors.Json["amdgpu-pci-0300"]["PPT"]["power1_average"];
        local max =  Sensors.Json["amdgpu-pci-0300"]["PPT"]["power1_cap"];

        if curr then
            curr = toInt(curr)
            local percent = "";
            if max then
                percent = toInt(curr / max * 100)
                if percent then
                    percent = math.floor(percent + 0.5)
                    percent = " (" .. toInt(curr / max * 100) .. "%)"
                end
            end
            return curr .. " W" .. percent
        end
    end
    return ""
end
