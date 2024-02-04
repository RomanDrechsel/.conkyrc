Processes = {}

function Processes:new()
    return self
end

function Processes:Display(cr, y)
    y = Draw:Header(cr, Locale.Processes, y)

    local width = (conky_window.width - (2 * Config.MarginX)) / 5

    Draw:Font(cr, Config.Text.Label)
    Draw:Text(cr, Locale.Name, Config.MarginX, y)
    Draw:RightText(cr, Locale.PID, y, Config.MarginX + (3 * width))
    Draw:RightText(cr, Locale.CPU, y, Config.MarginX + (4 * width))
    _, y = Draw:RightText(cr, Locale.MEM, y, Config.MarginX + (5 * width))

    Draw:Font(cr, Config.Text.Info)
    for i=1,11,1 do
        if y + getFontHeight(cr) > conky_window.height then
            break
        end

        Draw:Text(cr, conky_parse("${top name " .. i .. " }"), Config.MarginX, y)
        Draw:RightText(cr, trim(conky_parse("${top pid " .. i .. " }")), y, Config.MarginX + (3 * width))
        Draw:RightText(cr, trim(conky_parse("${top cpu " .. i .. " }")) .. "%", y, Config.MarginX + (4 * width))
        _, y = Draw:RightText(cr, trim(conky_parse("${top mem_res " .. i .. " }")), y, Config.MarginX + (5 * width))
    end

    return y
end

Processes:new()