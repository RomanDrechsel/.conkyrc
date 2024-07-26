Net = { CurrentIP = "-", CurrentPing = -1, _lastInet = nil}

function Net:new()
    self:_getIP()
    self:_getPing()
    print ("Network Init");
    return self
end

function Net:Update()
    if os.time() % 60 == 0 then
        self:_getIP()
    end

    if os.time() % 5 == 0 then
        self:_getPing()
    end
end

function Net:Ping()
    if self.CurrentPing == nil or self.CurrentPing <= 0 then
        local ret = "Kein Internet!"
        if self._lastInet == nil then
            local cache = read_cache("inet")
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

function Net:IP()
    if self.CurrentIP ~= nil then
        return self.CurrentIP;
    else
        return "-"
    end
end

function Net:_getIP()
    local ip = pipe("wget -q -O- http://ipecho.net/plain; echo &")
    if ip then
        self.CurrentIP = ip
    else
        self.CurrentIP = "-"
    end
end

function Net:_getPing()
    local ping = pipe("ping -c 1 -q -i 0.2 -w 1 google.com | awk -F'/' 'END{print int($6)}'")
    if ping then
        self.CurrentPing = tonumber(ping)
        self._lastInet = os.time()
        write_cache("inet", self._lastInet)
    else
        self.CurrentPing = 0
    end
end

Network = Net:new();
