require 'cairo'

local image = nil
local cs = nil
local cr = nil

function conky_main()
    if conky_window == nil or conky_window.width <= 0 or conky_window.height <= 0 then
        return
    end

    if image == nil then
        local script_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
        local image_path = script_dir .. "background.png"
        print("Conky Background: " .. image_path)
        image = cairo_image_surface_create_from_png(image_path)
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
end

function conky_kill()
    if image ~= nil then
        cairo_surface_destroy(image)
        image = nil
    end

    if cs ~= nil then
        cairo_surface_destroy(cs)
        cs = nil
    end

    if cr ~= nil then
        cairo_destroy(cr)
        cr = nil
    end
end
