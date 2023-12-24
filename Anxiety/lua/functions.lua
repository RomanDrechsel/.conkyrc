local fu = {}

function fu:trim(s)
    return tostring(s):match("^%s*(.-)%s*$")
end

function fu:isNotEmpty(string)
    return string ~= nil and string ~= ''
end

function fu:format_bytes(bytes)
    if bytes then
        local gigabytes = tonumber(self:trim(bytes)) / 1024 / 1024 / 1024
        local str = string.format("%.2f", gigabytes)
        return str
    end
    return -1
end

function fu:script_path()
    return debug.getinfo(1, "S").source:sub(2):match("(.*/)")
end

function fu:home()
    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
    if home then
        return home .. "/"
    end
    return ""
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

function fu:write_cache(file, content)
    local dir = fu:home() .. ".cache/conky/Anxiety/"
    os.execute("mkdir -p '" .. dir .. "'")

    local cache_file = io.open(dir .. file, "w")
    if cache_file then
        cache_file:write(content)
        cache_file:close()
    end
end

function fu:read_cache(file)
    local cache_file = io.open(fu:home() .. ".cache/conky/Anxiety/" .. file, "r")
    if cache_file then
        local content = cache_file:read("*a")
        cache_file:close()
        return content
    end

    return nil
end

return fu