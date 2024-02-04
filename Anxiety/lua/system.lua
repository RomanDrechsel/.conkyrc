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

    -- System + Kernel
    y = Draw:Row(cr, y, self.System, Config.Text.Label, nil, nil, self.Kernel, Config.Text.Info)

    -- Host + User
    y = Draw:Row(cr, y, Locale.Host, Config.Text.Label, nil, nil, self.Host .. " / " .. self.User, Config.Text.Info)

    -- Uptime
    y = Draw:Row(cr, y, Locale.Uptime, Config.Text.Label, nil, nil, uptime(), Config.Text.Info)

    -- processes
    y = Draw:Row(cr, y, Locale.Processes, Config.Text.Label, nil, nil, processes(), Config.Text.Info)

    return y
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