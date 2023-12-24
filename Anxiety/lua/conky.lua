local pwd = debug.getinfo(1, "S").source:match("@?(.*/)")
package.path = package.path .. ";" .. pwd .. "?.lua"

require('cairo')

local sensors = require("sensors")
local gpu = require("gpu_amd")
local cpu = require("cpu")
local harddisk = require("harddisk")
local ram = require("ram")
local net = require("network")

local image = nil
local cs = nil
local cr = nil

local Sensors = sensors:new()
local GPU = gpu:new(Sensors)
local Disk = harddisk:new(Sensors)
local CPU = cpu:new(Sensors)
local RAM = ram:new()
local NET = net:new()

function conky_init()

end

function conky_main()
    if conky_window == nil or conky_window.width <= 0 or conky_window.height <= 0 then
        return
    end

    if image == nil then
        image = cairo_image_surface_create_from_png(pwd .. "../background.png")
    end

    if image then
        if cs == nil or cr == nil then
            cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
            cr = cairo_create(cs)
            cairo_scale(cr, conky_window.width / cairo_image_surface_get_width(image), conky_window.height / cairo_image_surface_get_height(image))
            cairo_set_source_surface(cr, image, 0, 0)
        end 
        cairo_paint(cr)
    end

    if GPU then
        GPU:Update()
    end

    if Sensors then
        Sensors:Update()
    end

    if Disk then
        Disk:Update()
    end

    if RAM then
        RAM:Update()
    end
end

function conky_get_gpu_temp()
    if GPU then
        return GPU:Temp()
    end
    return ""
end

function conky_get_gpu_utilization()
    if GPU then
        return GPU:Utilization()
    end
    return "-"
end 

function conky_get_gpu_mem_temp()
    if GPU then
        return GPU:MemTemp()
    end
    return ""
end

function conky_get_gpu_vram()
    if GPU then
        return GPU:VRAM()
    end
    return "-"
end

function conky_get_gpu_power()
    if GPU then
        return GPU:Power()
    end
    return ""
end

function conky_get_gpu_fan()
    if GPU then
        return GPU:Fan()
    end
    return "-"
end

function conky_get_gpu_graph()
    if GPU then
        return GPU:Graph()
    end

    return ""
end

function conky_get_gpu()
    if GPU then
        return GPU:Card()
    end
end

function conky_get_gpu_driver()
    if GPU then
        return GPU:Driver()
    end
end

function conky_get_disk_temp()
    if Disk then
        return Disk:Temp()
    end
    return ""
end

function conky_get_disk_usage()
    if Disk then
        return Disk:Usage()
    end
    return ""
end

function conky_get_disk_percentage()
    if Disk then
        return Disk:Percentage()
    end
    return ""
end

function conky_get_cpu()
    if CPU then
        return CPU.CPUName
    end
    return "";
end

function conky_get_cpu_temp()
    if CPU then
        return CPU:Temp()
    end
    return "";
end

function conky_get_cpu_usage()
    if CPU then
        return CPU:Usage()
    end
    return "";
end

function conky_get_cpu_bar()
    if CPU then
        return CPU:Bar()
    end
    return "";
end

function conky_get_ram_usage()
    if RAM then
        return RAM:Usage()
    end
    return "-"
end

function conky_get_ram_percentage()
    if RAM then
        return RAM:Percentage()
    end
    return ""
end

function conky_get_ramswap_usage()
    if RAM then
        return RAM:UsageSwap()
    end
    return "-"
end

function conky_get_ramswap_percentage()
    if RAM then
        return RAM:PercentageSwap()
    end
    return ""
end

function conky_get_ping()
    if NET then
        return NET:Ping()
    end
    return "-"
end

function conky_get_externip()
    if NET then
        return NET.CurrentIP
    end
    return "-"
end

function conky_section_title(title)
    return "${voffset 10}${color1}${font1}".. title .. " ${hr 2}${voffset 3}"
end

function conky_process(index)
    return string.format("${font4}${top name %s } ${font5}${goto 135}${top pid %s } ${goto 190}${top cpu %s }%% ${alignr}${top mem_res %s }${voffset -1}", index, index, index, index)
end