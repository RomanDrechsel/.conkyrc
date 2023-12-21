local fu = {}

function fu:trim(s)
    return s:match("^%s*(.-)%s*$")
end

function fu:isNotEmpty(string)
    return string ~= nil and string ~= ''
end

function fu:format_bytes(bytes)
    local gigabytes = tonumber(self:trim(bytes)) / 1024 / 1024 / 1024
    local str = string.format("%.2f", gigabytes)
    return str:gsub( ",", ".")
end

function fu:script_path()
    return debug.getinfo(1, "S").source:sub(2):match("(.*/)")
end

function fu:dir_exists(dir)
    if self:pipe("[ -d '" .. dir .. "' ]") then
        return true
    else 
        return false
    end
end

function fu:pipe(command)
    local p = io.popen(command)
    if p then
        local output = p:read("*a")
        p:close()
        return self:trim(output)
    end
    return ""
end

function fu:package_installed(package)
    if self:isNotEmpty(self:pipe("which " .. package)) then
        return true
    end
    return false
end

function fu:toInt(number)
    number = tonumber(number)
    if number then
        return math.floor(number + 0.5)
    end
    return -1
end

return fu