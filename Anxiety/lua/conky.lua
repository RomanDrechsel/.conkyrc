--[[

Conky:
https://conky.cc/

]] --

pwd = debug.getinfo(1, "S").source:match("@?(.*/)")
package.path = package.path .. ";" .. pwd .. "../?.lua;" .. pwd .. "?.lua"

json = require("json")
require("functions")
require('config')
require('safe_config')
Config = safe_config(Config)

require('language/' .. Config.Language)
require('cairo')
require('cairo_xlib')

CacheDir = home() .. ".cache/conky/Anxiety/"

require('draw')
require('linegraph')
require('piegraph')
require('bargraph')
require("sensors")
require('clock')
require('system')
require("gpu_amd")
require("cpu")
require("harddisk")
require("ram")
require("network")
require("processes")

local background = nil

function conky_startup()
end

function conky_pre()
    if conky_window == nil or conky_window.width <= 0 or conky_window.height <= 0 then
        return
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

    if NET then
        NET:Update()
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual,
        conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    if background == nil and Config.BackgroundImage then
        background = cairo_image_surface_create_from_png(pwd .. "../" .. Config.BackgroundImage)
    end

    if Draw then
        Draw:Background(cr, background)
    end

    if cr then
        local y = Config.MarginY
        if Clock then
            y = Clock:Display(cr, y)
        end
        if System and y < conky_window.height then
            y = System:Display(cr, y)
        end
        if CPU and y < conky_window.height then
            y = CPU:Display(cr, y)
        end
        if RAM and y < conky_window.height then
            y = RAM:Display(cr, y)
        end
        if GPU and y < conky_window.height then
            y = GPU:Display(cr, y)
        end
        if Disk and y < conky_window.height then
            y = Disk:Display(cr, y)
        end
        if NET and y < conky_window.height then
            y = NET:Display(cr, y)
        end
        if Processes then
            y = Processes:Display(cr, y)
        end
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

function conky_shutdown()
end
