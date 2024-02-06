Clock = {}

function Clock:Display(cr, y)
    if Config.Clock then
        Draw:Font(cr, Config.Clock)
        _, y = Draw:CenterText(cr, os.date(Locale.Clock), y)
    end

    if Config.Date then
        Draw:Font(cr, Config.Date)
        _, y = Draw:CenterText(cr, os.date(Locale.Date), y)
    end
    
    return y
end