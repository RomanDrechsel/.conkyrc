NET = { CurrentIP = "-", CurrentPing = -1, _lastInet = nil}

function NET:new()
    self:_getIP()
    self:_getPing()
    self._json = nil
    if Config.NetworkGraph then
        self.Graph = LineGraph:new(Config.LineGraph, nil, 70)

        self.Graph.Lines = {
            ["down"] = Config.NetworkGraph.Download,
            ["up"] = Config.NetworkGraph.Upload,
        }
    end
    return self
end

function NET:Display(cr, y)
    y = Draw:Header(cr, Locale.Network, y)

    y = Draw:Row(cr, y, Locale.ExternIP, Config.Text.Label, nil, nil, Locale.Ping, nil)

    y = Draw:Row(cr, y, self.CurrentIP, Config.Text.Large, nil, nil, self:Ping(), nil)

    if self._json and self.Graph then
        local down = self._json["speed_down"]
        local up = self._json["speed_up"]
        local speed = self:Speed()
        local total = self:Total()
        if (speed and speed ~= "") or (total and total ~= "") then
            y = Draw:Row(cr, y, speed, Config.Text.Info, nil, nil, total, nil)
        end

        local data = {
            ["down"] = down,
            ["up"] = up,
        }

        y = self.Graph:Draw(cr, Config.MarginX, y + 5, data)
    end

    return y
end

function NET:Update()
    if Config.Network and Config.Network.Interface then
        os.execute(pwd .. "../bash/network.sh \"" .. Config.Network.Interface .. "\" \"" .. CacheDir .."network\" &")
    end

    if os.time() % 60 == 0 then
        self:_getIP()
    end

    if os.time() % 5 == 0 then
        self:_getPing()
    end

    local cache = read_cache("network")
    if cache then
        local success, _json = pcall(json.parse, cache)
        if success and _json and _json ~= json.null then
            self._json = _json
        else
            self._json = nil
        end
    else
        self._json = nil
    end
end

function NET:Speed()
    if self._json then
        local down = self._json["speed_down"]
        local up = self._json["speed_up"]

        if up or down then
            local ret = ""
            if down then
                ret = format_bytes(down)
            else
                ret = "-"
            end

            ret = ret .. " / ";
            if up then
                ret = ret .. format_bytes(up)
            else
                ret = ret .. "-"
            end

            return ret
        end
    end

    return nil
end

function NET:Total()
    if self._json then
        local down = self._json["total_down"]
        local up = self._json["total_up"]

        if up or down then
            local ret = ""
            if down then
                ret = format_bytes(down)
            else
                ret = "-"
            end

            ret = ret .. " / ";
            if up then
                ret = ret .. format_bytes(up)
            else
                ret = ret .. "-"
            end

            return ret
        end
    end

    return nil
end

function NET:Ping()
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

function NET:_getIP()
    local ip = pipe("wget -q -O- http://ipecho.net/plain; echo &")
    if ip then
        self.CurrentIP = ip
    else
        self.CurrentIP = "-"
    end
end

function NET:_getPing()
    local ping = pipe("ping -c 1 -q -i 0.2 -w 1 google.com | awk -F'/' 'END{print int($6)}'")
    if ping then
        self.CurrentPing = tonumber(ping)
        self._lastInet = os.time()
        write_cache("inet", self._lastInet)
    else
        self.CurrentPing = 0
    end
end

NET:new()
