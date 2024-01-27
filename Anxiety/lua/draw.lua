-- https://www.cairographics.org/manual/
-- https://github.com/lutherush/conky/blob/master/conky/pie-ring-text/text.lua

Draw = {}

function Draw:Background(cr, image)
    if cr and image then
        cairo_scale(cr, conky_window.width / cairo_image_surface_get_width(image), conky_window.height / cairo_image_surface_get_height(image))
        cairo_set_source_surface(cr, image, 0, 0)
        cairo_paint(cr)
        cairo_identity_matrix(cr)
    end
end

function Draw:Text(cr, text, x, y)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)

    y = y + getFontHeight(cr)

    cairo_move_to(cr, x, y)
    cairo_show_text(cr, text)
    cairo_stroke(cr)

    x = x + extents.x_advance
    return x,y
end

function Draw:LeftText(cr, text, y)
    return self:Text(cr, text, Config.MarginX, y)
end

function Draw:CenterText(cr, text, y)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)

    local x = (conky_window.width / 2) - (extents.width / 2)
    return self:Text(cr, text, x, y)
end

function Draw:RightText(cr, text, y)
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, text, extents)

    local x = conky_window.width - extents.width - Config.MarginX
    return self:Text(cr, text, x, y)
end

function Draw:Font(cr, font)
    if font then
        if font.FontFamily then
            local weight = CAIRO_FONT_WEIGHT_NORMAL
            if font.Bold then
                weight = CAIRO_FONT_WEIGHT_BOLD
            end
            cairo_select_font_face(cr, font.FontFamily, CAIRO_FONT_SLANT_NORMAL, weight)
        end
        if font.FontSize then
            cairo_set_font_size(cr, font.FontSize)
        end

        self:Color(cr, font.FontColor)
    end
end

function Draw:Color(cr, color)
    if color then
        local c1, c2, c3, c4 = hexToRGBA(color)
        if c4 >= 1 then
            cairo_set_source_rgb(cr, c1, c2, c3)
        else
            cairo_set_source_rgba(cr, c1, c2, c3, c4)
        end
    end
end

function Draw:Header(cr, text, y)

    y = y + (Config.Padding * 4)

    self:Font(cr, Config.Header)
    local x, y = self:Text(cr, text, Config.MarginX, y)
    x = x + 10

    self:Line(cr, x, y - 2, -1, y - 2, 2)

    y = y + (Config.Padding * 2)

    return y
end

function Draw:Line(cr, x1, y1, x2, y2, linewidth, color)
    if linewidth == nil or linewidth <= 0 then
        linewidth = 1
    end

    self:Color(cr, color)

    if x2 < 0 then
        x2 = conky_window.width - Config.MarginX
    end

    cairo_move_to(cr, x1, y1)
    cairo_line_to(cr, x2, y2)
    cairo_set_line_width(cr, linewidth)
    cairo_stroke(cr)
end

function Draw:Rect(cr, x, y, width, height, lineheight, bordercolor)
    if width < 0 then
        width = conky_window.width - x - Config.MarginX
    end

    if lineheight == nil or lineheight <= 0 then
        return
    end

    self:Color(cr, bordercolor)

    cairo_rectangle(cr, x, y, width, height)
    cairo_set_line_width(cr, lineheight)
    cairo_stroke(cr)
end

function Draw:FillRect(cr, x, y, width, height, color)
    if width < 0 then
        width = conky_window.width - x - Config.MarginX
    end

    self:Color(cr, color)
    cairo_rectangle(cr, x, y, width, height)
    cairo_fill(cr)
end

function Draw:Polygon(cr, points, color, linewidth)
    if #points < 4 or linewidth == nil or linewidth <= 0 then
        return
    end

    self:Color(cr, color)

    cairo_move_to(cr, points[1], points[2])

    local i = 3
    while i < #points do
        if i > #points - 1 then
            break
        end

        cairo_line_to(cr, points[i], points[i+1])
        i = i + 2
    end
    cairo_stroke(cr)
end

function Draw:FillPolygon(cr, points, color)
    if #points < 4 or color == nil then
        return
    end

    self:Color(cr, color)

    cairo_move_to(cr, points[1], points[2])

    local i = 3
    while i < #points do
        if i > #points - 1 then
            break
        end

        cairo_line_to(cr, points[i], points[i+1])
        i = i + 2
    end
    cairo_fill(cr)
end

function Draw:Circle(cr, cx, cy, r, color, linewidth)
    self:Arc(cr, cx, cy, r, color, linewidth, 0, 2 * math.pi)
end

function Draw:Arc(cr, cx, cy, r, color, linewidth, a_start, a_end)
    if linewidth == nil or linewidth <= 0 or r == nil or r <= 0 then
        return
    end

    self:Color(cr, color)
    print("ARC: " .. a_start .. " to " .. a_end .. "(" .. math.deg(a_start) .. "° to " .. math.deg(a_end) ..  "°)")
    cairo_arc_negative(cr, cx, cy, r, a_start, a_end)
    cairo_set_line_width(cr, linewidth)
    cairo_stroke(cr)
end

function hexToRGBA(hex)
    if hex == nil then
        return 1, 1, 1, 1
    end

    hex = hex:gsub("#", "")
    local hexWithoutAlpha = hex:sub(1, 6)
    local alphaHex = hex:sub(7, 8)
    local r = tonumber(hexWithoutAlpha:sub(1, 2), 16) / 255
    local g = tonumber(hexWithoutAlpha:sub(3, 4), 16) / 255
    local b = tonumber(hexWithoutAlpha:sub(5, 6), 16) / 255

    local a = 1
    if isEmpty(alphaHex) == false then
        a = tonumber(alphaHex, 16) / 255
    end

    return r, g, b, a
end

function getFontHeight(cr)
    local font_extents = cairo_font_extents_t.create()
    cairo_font_extents(cr, font_extents)
    return font_extents.height
end