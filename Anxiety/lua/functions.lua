function trim(s)
    return tostring(s):match("^%s*(.-)%s*$")
end

function isEmpty(string)
    return string == nil or string == ''
end

function in_array (tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end


function format_bytes(bytes)
    if bytes then
        bytes = tonumber(trim(bytes))
        if bytes > 1073741824 then
            local gigabytes = bytes / 1073741824
            local str = string.format("%.2f", gigabytes)
            return str .. " Gb"
        elseif bytes > 1048576 then
            local megabytes = bytes / 1048576
            local str = string.format("%.2f", megabytes)
            return str .. " Mb"
        elseif bytes > 1024 then
            local kilobytes = bytes / 1048576
            local str = string.format("%.2f", kilobytes)
            return str .. " Kb"
        else    
            return bytes .. " b"
        end
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

function file_exists(file)
    if pipe("[ -f '" .. file .. "' ]") then
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

function table.copy(t)
    local ret = {};
    for k,v in pairs(t) do
        if type(v) == "table" then
            ret[k] = table.copy(v);
        else
            ret[k] = v;
        end
    end
    return ret;
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

function split(str, delimiter)
    if delimiter == nil then
        delimiter = "\n"
    end
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( str, delimiter, from  )
    while delim_from do
        table.insert( result, string.sub( str, from , delim_from-1 ) )
        from  = delim_to + 1
        delim_from, delim_to = string.find( str, delimiter, from  )
    end
    table.insert( result, string.sub( str, from  ) )
    return result
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end
