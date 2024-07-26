pwd = debug.getinfo(1, "S").source:match("@?(.*/)")
package.path = package.path .. ";" .. pwd .. "../?.lua;" .. pwd .. "?.lua"

require('cairo')
require('json')
json = require("json")
require('functions')
require('sensors')
require('amd_gpu')
require('network')
require('disk')
require('cpu')

function conky_clock()
    return [[
${color 72aeef}${font EP Boxi:size=30}${alignc}${time %H:%M:%S}
${color ffffff}${font Young Serif:size=20}${alignc}${time %A, %d. %B %Y}${font}${color}]]
end

function conky_system()
    return [[${voffset 10}${color c587ff}${font EP Box:size=16}System ${hr 3}${font}${color}
${font Roboto Slab:size=11}${execi 3600 lsb_release -ds}${alignr}${kernel}
${goto 150}Uptime:${alignr}${uptime}
${goto 150}Prozesse: ${alignr}${processes}]]
end

function conky_cpu()
    return [[${voffset 10}${color c587ff}${font EP Box:size=16}CPU ${hr 3}${font}${color}
${cpu cpu0}% ${goto 50}${color 6495ff}${voffset 2}${cpubar 14}${color}
Temperatur:${alignr}]] .. getCpuTemp() .. [[

${color 6495ff}${cpugraph cpu0 ff0000 00ff00 -t }]]
end

function conky_memory()
    return [[${voffset 10}${color c587ff}${font EP Box:size=16}Memory ${hr 3}${font}${color}
${mem} / ${memmax}${color 00ff00}${color 6495ff}${goto 200}${voffset 2}${membar}
${color 6495ff}${memgraph ff0000 00ff00 -t}]]
end

function conky_disk()
    local ret = [[${voffset 10}${color c587ff}${font EP Box:size=16}Festplatte ${hr 3}${font}${color}
Temperatur:${alignr}]] .. Disk:Temp() .. [[
]]
    for _, part in ipairs(Disk.Partitions) do
        local usage  = Disk:Usage(part)
        local percent = Disk:Percent(part)
        if usage and percent then
            ret = ret .. "\n" .. part .. "${alignr}" .. usage .. "\n" .. "${color 6495ff}${execbar echo ".. percent .."}${color}"
        end
    end

    return ret;
end

function conky_gpu()
    return [[${voffset 10}${color c587ff}${font EP Box:size=16}Grafikkarte ${hr 3}${font}${color}
AMD Radeon RX 7800 XT ${alignr}${execi 3600 glxinfo | grep "OpenGL core profile version string" | awk -F'[()]' ' {print $3}' | awk '{print $1, $2}'}
${color 6495ff}${lua_graph conky_getGpuLoad}${color}
GPU: ${goto 150}]] .. conky_getGpuLoad() .. [[% ${alignr}]]..conky_getGpuUtil()..[[

VRAM: ${alignr}]].. conky_getGpuVRAM() .. [[

Temp: ${alignr}]] .. conky_getGpuTemp() .. [[

Lüfter: ${alignr}]] .. conky_getGpuFan() .. [[

Verbrauch: ${alignr}]] .. conky_getGpuPower()
end

function conky_network()
    return [[${voffset 10}${color c587ff}${font EP Box:size=16}Netzwerk ${hr 3}${font}${color}
Down: ${goto 60}${downspeed enp0s31f6} ${goto 200}Up: ${goto 250} ${upspeed enp0s31f6}
${goto 60}${totaldown enp0s31f6} ${goto 250} ${totalup enp0s31f6}
IP:${goto 60}]] .. Network:IP() .. [[ ${goto 200}Ping: ${goto 250} ]] .. Network:Ping() .. [[

${color 6495ff}${downspeedgraph enp0s31f6 80,175} ${alignr}${upspeedgraph enp0s31f6 80,175 }]]
end

function conky_processes()
    return [[${voffset 10}${color c587ff}${font EP Box:size=16}Prozesse ${hr 3}${font}${color}
${goto 180}PID${goto 230}CPU${goto 300}MEM
${top name 1}${goto 160}${top pid 1}${goto 220}${top cpu 1}%${goto 290}${top mem_res 1}
${top name 2}${goto 160}${top pid 2}${goto 220}${top cpu 2}%${goto 290}${top mem_res 2}
${top name 3}${goto 160}${top pid 3}${goto 220}${top cpu 3}%${goto 290}${top mem_res 3}
${top name 4}${goto 160}${top pid 4}${goto 220}${top cpu 4}%${goto 290}${top mem_res 4}
${top name 5}${goto 160}${top pid 5}${goto 220}${top cpu 5}%${goto 290}${top mem_res 5}
${top name 6}${goto 160}${top pid 6}${goto 220}${top cpu 6}%${goto 290}${top mem_res 6}
${top name 7}${goto 160}${top pid 7}${goto 220}${top cpu 7}%${goto 290}${top mem_res 7}
${top name 8}${goto 160}${top pid 8}${goto 220}${top cpu 8}%${goto 290}${top mem_res 8}
${top name 9}${goto 160}${top pid 9}${goto 220}${top cpu 9}%${goto 290}${top mem_res 9}
${top name 10}${goto 160}${top pid 10}${goto 220}${top cpu 10}%${goto 290}${top mem_res 10}]]
end

local background = nil
function conky_pre()
    if conky_window == nil or conky_window.width <= 0 or conky_window.height <= 0 then
        return
    end

    if Sensors then
        Sensors:Update()
    end

    if Network then
        Network:Update()
    end

    if Disk then
        Disk:Update()
    end

    return
    --[[
    if background == nil then
        background = cairo_image_surface_create_from_png(pwd .. "../background.png")
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)
    if cr and background then
        cairo_scale(cr, conky_window.width / cairo_image_surface_get_width(background), conky_window.height / cairo_image_surface_get_height(background))
        cairo_set_source_surface(cr, background, 0, 0)
        cairo_paint(cr)
        cairo_identity_matrix(cr)
    end
    ]]--
end
