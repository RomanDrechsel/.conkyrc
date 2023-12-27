function trim(s)
    return tostring(s):match("^%s*(.-)%s*$")
end

function isEmpty(string)
    return string == nil or string == ''
end

function format_bytes(bytes)
    if bytes then
        local gigabytes = tonumber(trim(bytes)) / 1024 / 1024 / 1024
        local str = string.format("%.2f", gigabytes)
        return str
    end
    return -1
end

function home()
    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
    if home then
        return home .. "/"
    end
    return ""
end

function dir_exists(dir)
    if pipe("[ -d '" .. dir .. "' ]") then
        return true
    else 
        return false
    end
end

function pipe(command)
    local p = io.popen(command)
    if p then
        local output = p:read("*a")
        p:close()
        return trim(output)
    end
    return ""
end

function package_installed(package)
    if pipe("which " .. package) then
        return true
    end
    return false
end

function toInt(number)
    number = tonumber(number)
    if number then
        return math.floor(number + 0.5)
    end
    return -1
end

function write_cache(file, content)
    local dir = home() .. ".cache/conky/Anxiety/"
    os.execute("mkdir -p '" .. dir .. "'")

    local cache_file = io.open(dir .. file, "w")
    if cache_file then
        cache_file:write(content)
        cache_file:close()
    end
end

function read_cache(file)
    local cache_file = io.open(home() .. ".cache/conky/Anxiety/" .. file, "r")
    if cache_file then
        local content = cache_file:read("*a")
        cache_file:close()
        return content
    end

    return nil
end