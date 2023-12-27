Clock = {}

function Clock:Display(cr, y)
    Draw:Font(cr, Config.Clock)
    _, y = Draw:CenterText(cr, os.date(Locale.Clock), y)

    Draw:Font(cr, Config.Date)
    _, y = Draw:CenterText(cr, os.date(Locale.Date), y)
    
    return y
end