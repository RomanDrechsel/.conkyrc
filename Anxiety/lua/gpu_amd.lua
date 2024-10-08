GPU = { Path = nil, DriverVersion = "", CardName = "" }

function GPU:new()
    self.Path = "/sys/class/drm/"
    local card = pipe("ls " .. self.Path .. " | grep -E '^card[0-9]+$' | tail -n 1")
    if card == nil or string.len(card) == 0 then
        card = "card0"
    end

    self.Path = self.Path .. card .. "/device/"

    if dir_exists(self.Path) then
        print("AMD-GPU Device found: " .. self.Path)
    else
        GPU.Path = nil
        print("No AMD-GPU Device found!")
    end

    self.DriverVersion = nil
    if Config.VideoCard then
        self.CardName = Config.VideoCard
    else
        local card = pipe("glxinfo -B | grep -A 10 \"Extended renderer info\" | grep -E \"Device:\"")
        if card then
            local gpuName = card:match("Device:%s+(.-)%s*%(.+%s*%)")
            if gpuName then
                self.CardName = gpuName
            end
        end
    end

    if Config.LineGraph.Graph.LineColor and Config.LineGraph.Graph.LineWidth and Config.LineGraph.Graph.LineWidth > 0 then
        self.GraphLine = LineGraph:new(Config.LineGraph, nil, 60)
    end

    self._runOncePerMin(self)

    return self
end

function GPU:Display(cr, y)
    y = Draw:Header(cr, Locale.VideoCard, y)

    y2 = y

    -- card name
    if self.CardName and self.CardName ~= nil then
        if Config.Text then
            Draw:Font(cr, Config.Text.Special)
        end

        _, y = Draw:LeftText(cr, self.CardName, y)
        y = y + 5
    end

    -- driver version
    if self.DriverVersion then
        Draw:Font(cr, Config.Text.Info)
        Draw:RightText(cr, self.DriverVersion, y2)
    end

    -- graph
    if self.GraphLine and self.Path and file_exists(self.Path .. "/gpu_busy_percent") then
        local util = pipe("cat " .. self.Path .. "/gpu_busy_percent")
        if util == nil then
            util = 0
        end
        y = self.GraphLine:Draw(cr, Config.MarginX, y, util)
    end

    -- Utilization / Temperature
    local temp = self:Temp()
    if temp and temp ~= "" then
        y = Draw:Row(cr, y, Locale.GPU, Config.Text.Label, self:Temp(), Config.Text.Info, self:Utilization(), nil);
    end

    -- Memory
    local mem = self:VRAM()
    local memtmp = self:MemTemp()
    if (mem and mem ~= "-") or (memtmp and memtmp ~= "") then
        y = Draw:Row(cr, y, Locale.Memory, Config.Text.Label, self:MemTemp(), Config.Text.Info, self:VRAM(), nil);
    end

    -- Fan
    local fan = self:Fan()
    if fan and fan ~= "-" then
        y = Draw:Row(cr, y, Locale.Fan, Config.Text.Label, nil, nil, self:Fan(), Config.Text.Info);
    end

    -- Power
    local power = self:Power()
    if power and power ~= "-" then
        y = Draw:Row(cr, y, Locale.Power, Config.Text.Label, nil, nil, self:Power(), Config.Text.Info);
    end

    return y
end

function GPU:Update()
    if os.time() % 60 == 0 then
        self:_runOncePerMin()
    end
end

function GPU:VRAM()
    if self.Path then
        local used = pipe("cat " .. self.Path .. "mem_info_vram_used")
        local max =  pipe("cat " .. self.Path .. "mem_info_vram_total")

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
    return "-"
end

function GPU:Temp()
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

function GPU:Utilization()
    if self.Path then
        local curr = pipe("grep -Pom 1 '\\d+:\\s\\K(\\d+)(?=.*\\*$)' " .. self.Path .. "pp_dpm_sclk")
        local max = pipe("cat " .. self.Path .. "pp_dpm_sclk | tail -1 | cut -c4-7")

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
    end
    return "-"
end

function GPU:MemTemp()
    if Sensors and Sensors.Json then
        local temp = Sensors.Json["amdgpu-pci-0300"]["mem"]["temp3_input"];
        if temp then
            return toInt(temp) .. "°C"
        end
    end

    return ""
end

function GPU:Fan()
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

    return "-"
end

function GPU:Power()
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
    return "-"
end

function GPU:_runOncePerMin()
    local glxinfo = pipe("glxinfo -B | grep -A 10 \"Extended renderer info\" | grep -E \"Version:\"")
    if glxinfo then
        local driver = glxinfo:match("Version:(.+)")
        if driver then
            self.DriverVersion = trim(driver)
        end
    end
end

GPU:new()
