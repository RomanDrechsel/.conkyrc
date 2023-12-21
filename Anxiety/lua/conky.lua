local pwd = debug.getinfo(1, "S").source:match("@?(.*/)")
package.path = package.path .. ";" .. pwd .. "?.lua"

require('cairo')

local fu = require("functions")
local sensors = require("sensors")
local gpu = require("gpu_amd")
local harddisk = require("harddisk")

local image = nil
local cs = nil
local cr = nil
local ping = nil
local last_inet = nil

local Sensors = sensors:new()
local GPU = gpu:new(Sensors)
local Disk = harddisk:new(Sensors)

function conky_init()

end

function conky_main()
    if conky_window == nil or conky_window.width <= 0 or conky_window.height <= 0 then
        return
    end

    if image == nil then
        image = cairo_image_surface_create_from_png(pwd .. "../background.png")
    end

    if image ~= nil then
        if cs == nil or cr == nil then
            cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
            cr = cairo_create(cs)
            cairo_scale(cr, conky_window.width / cairo_image_surface_get_width(image), conky_window.height / cairo_image_surface_get_height(image))
            cairo_set_source_surface(cr, image, 0, 0)
        end 
        cairo_paint(cr)
    end

    if Sensors ~= nil then
        Sensors:Update()
    end

    if Disk ~= nil then
        Disk:Update()
    end

    if ping == nil or os.date("%S") % 5 == 0 then
        update_ping()
    end
end

function conky_get_gpu_temp()
    if GPU ~= nil then
        return GPU:Temp()
    end
    return ""
end

function conky_get_gpu_utilization()
    if GPU ~= nil then
        return GPU:Utilization()
    end
    return "-"
end 

function conky_get_gpu_mem_temp()
    if GPU ~= nil then
        return GPU:MemTemp()
    end
    return ""
end

function conky_get_gpu_vram()
    if GPU ~= nil then
        return GPU:VRAM()
    end
    return "-"
end

function conky_get_gpu_power()
    if GPU ~= nil then
        return GPU:Power()
    end
    return ""
end

function conky_get_gpu_fan()
    if GPU ~= nil then
        return GPU:Fan()
    end
    return "-"
end

function conky_get_ssd_temp()
    if Disk ~= nil then
        return Disk:Temp()
    end
    return "123"
end

function conky_get_cpu_temp()
    return get_sensor_data("Composite"):gsub( "+", "")
end

function conky_section_title(title)
    return "${voffset 10}${color1}${font1}".. title .. " ${hr 2}${voffset 3}"
end

function conky_process(index)
    return string.format("${font4}${top name %s } ${font5}${goto 135}${top pid %s } ${goto 190}${top cpu %s }%% ${alignr}${top mem_res %s }${voffset -1}", index, index, index, index)
end

function conky_get_ping()
    if ping == nil or ping <= 0 then
        local ret = "Kein Internet!"
        if last_inet == nil then
            local inet_cache_file = io.open(".cache/Conky/Anxiety/inet", "r")
            if inet_cache_file then
                last_inet = tonumber(inet_cache_file:read("*a"))
                inet_cache_file:close()
            end
        end
        if last_inet ~= nil then
            local diff = os.time() - last_inet
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
        return ping .. " ms"
    end
end

function get_sensor_data(sensor_name)
    return fu:pipe("sensors | grep '" .. sensor_name .. "' | awk '{print $2}'")
end

function update_ping()
    ping = tonumber(fu:pipe("ping -c 1 -q -i 0.2 -w 1 google.com | awk -F'/' 'END{print int($6)}'"))
    if ping ~= nil and ping > 0 then
        last_inet = os.time()
        local dir = ".cache/Conky/Anxiety"
        os.execute("mkdir -p '" .. dir .. "'")
        local inet_cache_file = io.open(dir .. "/inet", "w")
        if inet_cache_file then
            inet_cache_file:write(last_inet)
            inet_cache_file:close()
        end
    end
end