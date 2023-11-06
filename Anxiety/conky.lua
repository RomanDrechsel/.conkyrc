require 'cairo'

local image = nil
local cs = nil
local cr = nil
local gpu = nil

function conky_main()
    if gpu == nil then
        gpu = "/sys/class/drm/"
        local card = pipe("ls " .. gpu .." | grep -E '^card[0-9]+$'")
        if card == nil or string.len(card) == 0 then
            card = "card0"
        end
        gpu = gpu .. card .. "/device/"
    end

    if conky_window == nil or conky_window.width <= 0 or conky_window.height <= 0 then
        return
    end

    if image == nil then
        local script_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
        local image_path = script_dir .. "background.png"
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

function conky_get_gpu_temp()
    return trim(get_sensor_data("edge")):gsub( "+", "") .. " / " .. trim(get_sensor_data("junction")):gsub( "+", "")
end

function conky_get_gpu_utilization()
    if (gpu == nil) then
        return ""
    end
    local dpm_sclk = tonumber(pipe("grep -Pom 1 '\\d+:\\s\\K(\\d+)(?=.*\\*$)' " .. gpu .. "pp_dpm_sclk"))
    local last_sclk = tonumber(pipe("cat " .. gpu .. "pp_dpm_sclk | tail -1 | cut -c4-7"))
    return dpm_sclk .. " Mhz / " .. last_sclk .. " Mhz"
end 

function conky_get_gpu_mem_temp()
    return trim(get_sensor_data("mem")):gsub( "+", "")
end

function conky_get_gpu_vram()
    if (gpu == nil) then
        return ""
    end
    local used = pipe("cat " .. gpu .. "mem_info_vram_used")
    local max =  pipe("cat " .. gpu .. "mem_info_vram_total")
    return format_bytes(used) .. " Gb / " .. format_bytes(max) .. " Gb"
end

function conky_get_gpu_power()
    return get_sensor_data("PPT") .. " W"
end

function conky_get_gpu_fan()
    local curr = tonumber(pipe("sensors | grep -i fan1 | awk '{print $2}'"))
    local max =  tonumber(pipe("sensors | grep -i fan1 | awk '{print $10}'"))
    local percent = tonumber(curr / max * 100)
    return curr .." RPM (" .. math.floor(percent + 0.5) .. "%)"
end

function conky_get_ssd_temp()
    return pipe("sensors | grep 'Package id 0' | awk '{print $4}'"):gsub( "+", "")
end

function conky_get_cpu_temp()
    return get_sensor_data("Composite"):gsub( "+", "")
end

function get_sensor_data(sensor_name)
    return pipe("sensors | grep '" .. sensor_name .. "' | awk '{print $2}'")
end 

function pipe(command)
    local pipe = io.popen(command)
    local output = pipe:read("*a");
    pipe:close();
    return trim(output)
end

function trim(s)
    return s:match "^%s*(.-)%s*$"
end

function format_bytes(bytes)
    local gigabytes = tonumber(trim(bytes)) / 1024 / 1024 / 1024
    local str = string.format("%.2f", gigabytes)
    return str:gsub( ",", ".")
end
