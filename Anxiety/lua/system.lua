System = {}

local uptime
local processes

function System:new()
    local sys = pipe("hostnamectl | grep \"Operating System:\"")
    if sys then
        self.System = sys:match("Operating System:%s+(.-)%s+%(")
    end

    if isEmpty(self.System) then
        self.System = pipe("cat /etc/os-release | grep PRETTY_NAME | awk -F'\"' '{gsub(/\\(.*)/, \"\", $2); gsub(/\\(.*)/, \"\", $2); print $2}'")
    end

    local uname = pipe("uname -a")
    if uname then
        local _, host, kernel = uname:match("(%S+)%s+(%S+)%s+(%S+)")
        if host then
            self.Host = trim(host)
        end
        if kernel then
            self.Kernel = trim(kernel)
        end
    end

    self.User = pipe("whoami")

    return self
end

function System:Display(cr, y)
    y = Draw:Header(cr, Locale.System, y)

    local b = y

    -- System + Kernel
    if self.System then
        if Config.Text then
            Draw:Font(cr, Config.Text.Label)
        end
        _,b = Draw:LeftText(cr, self.System, y)
    end
    if self.Kernel then
        if Config.Text then
            Draw:Font(cr, Config.Text.Info)
        end
        local _,b2 = Draw:RightText(cr, self.Kernel, y);
        if b2 > b then
            b = b2
        end
    end

    -- Host + User
    y = b + Config.Padding
    if Config.Text then
        Draw:Font(cr, Config.Text.Label)
    end
    _,b = Draw:LeftText(cr, Locale.Host, y)

    if Config.Text then
        Draw:Font(cr, Config.Text.Info)
    end
    local _,b2 = Draw:RightText(cr, self.Host .. " / " .. self.User, y);
    if b2 > b then
        b = b2
    end

    -- Uptime
    y = b + Config.Padding
    if Config.Text then
        Draw:Font(cr, Config.Text.Label)
    end
    _,b = Draw:LeftText(cr, Locale.Uptime, y)

    if Config.Text then
        Draw:Font(cr, Config.Text.Info)
    end
    _,b2 = Draw:RightText(cr, uptime(), y);
    if b2 > b then
        b = b2
    end

    -- processes
    y = b + Config.Padding
    if Config.Text then
        Draw:Font(cr, Config.Text.Label)
    end
    _,b = Draw:LeftText(cr, Locale.Processes, y)

    if Config.Text then
        Draw:Font(cr, Config.Text.Info)
    end
    _,b2 = Draw:RightText(cr, processes(), y);
    if b2 > b then
        b = b2
    end

    return b
end

System:new()

function uptime()
    local uptimeCommandOutput = pipe("uptime -s")
    if uptimeCommandOutput then
        local year, month, day, hour, min, sec = uptimeCommandOutput:match("(%d+)%-(%d+)%-(%d+)%s+(%d+):(%d+):(%d+)")

        local startTimestamp = os.time{year=year,
                                        month=month,
                                        day=day,
                                        hour=hour,
                                        min=min,
                                        sec=sec}

        local uptimeSeconds = os.time() - startTimestamp

        local days = math.floor(uptimeSeconds / 3600 / 24)
        local hours = math.floor(uptimeSeconds / 3600)
        local minutes = math.floor((uptimeSeconds % 3600) / 60)
        local seconds = uptimeSeconds % 60

        local ret = seconds .."s"
        if uptimeSeconds >= 60 then
            ret = minutes .. "m " .. ret
        end
        if uptimeSeconds >= 3600 then
            ret = hours .. "h " .. ret
        end
        if uptimeSeconds >= 86400 then
            ret = days .. "d " .. ret
        end

        return ret
    end
    return ""
end

function processes()
    local pse = pipe("ps -e | wc -l")
    local psu = pipe("ps -U \"" .. System.User .. "\" | wc -l")

    if pse then
        if pse == psu or psu == nil then
            return pse
        else
            return psu .. " (" .. pse .. ")"
        end
    end

    return ""
end