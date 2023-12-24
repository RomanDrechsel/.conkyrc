local fu = require("functions")

local NET = { CurrentIP = "-", CurrentPing = -1, _lastInet = nil}

function NET:new()
    self:_getIP()
    self:_getPing()
    return self
end

function NET:Update()
    if os.time() % 60 then
        self:_getIP()
    end

    if os.time() % 5 then
        self:_getPing()
    end
end

function NET:Ping()
    if self.CurrentPing == nil or self.CurrentPing <= 0 then
        local ret = "Kein Internet!"
        if self._lastInet == nil then
            local cache = fu:read_cache("inet")
            if cache  then
                self._lastInet = tonumber(cache)
            end
        end

        if self._lastInet then
            local diff = os.time() - self._lastInet
            local min = math.floor((diff / 60) + 0.5)
            local hours = math.floor((min / 3600) + 0.5)
            if hours > 0 then
                ret = ret .. " (" .. hours .. "h " .. min .."m)"
            else
                ret = ret .. " (" .. min .."m)"
            end
        end
        return ret
    else
        return self.CurrentPing .. " ms"
    end
end

function NET:_getIP()
    local ip = fu:pipe("wget -q -O- http://ipecho.net/plain; echo &")
    if ip then
        self.CurrentIP = ip
    else
        self.CurrentIP = "-"
    end
end

function NET:_getPing()
    local ping = fu:pipe("ping -c 1 -q -i 0.2 -w 1 google.com | awk -F'/' 'END{print int($6)}'")
    if ping then
        self.CurrentPing = tonumber(ping)
        self._lastInet = os.time()
        fu:write_cache("inet", self._lastInet)
    end
end

return NET
