local pwd = debug.getinfo(1, "S").source:match("@?(.*/)")
package.path = package.path .. ";" .. pwd .. "../?.lua;" .. pwd .. "?.lua"

Config = {}
Config.BackgroundImage = "background.png"

json = require("json")
require('config')
require('language/de')
require('cairo')
require("functions")
require('draw')
require('linegraph')
require('piegraph')
require("sensors")
require('clock')
require('system')
require("gpu_amd")
require("cpu")
require("harddisk")
require("ram")
require("network")
local background = nil

function conky_startup()
end

function conky_pre()
    if conky_window == nil or conky_window.width <= 0 or conky_window.height <= 0 then
        return
    end

    if background == nil then
        background = cairo_image_surface_create_from_png(pwd .. "../" .. Config.BackgroundImage)
    end

    if Sensors then
        Sensors:Update()
    end

    if GPU then
        GPU:Update()
    end

    if Disk then
        Disk:Update()
    end

    if RAM then
        RAM:Update()
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    if Draw then
        Draw:Background(cr, background)
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

function conky_shutdown()
    if background then
        print("Destory background...")
        --cairo_destroy(background)
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
    return ""
end

function conky_get_gpu_driver()
    if GPU then
        return GPU:Driver()
    end
    return ""
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