Config = {}

-- Background Image
Config.BackgroundImage = "background.png"
Config.MarginY = 10
Config.MarginX = 5
Config.Padding = 3

-- Clock
Config.Clock = {
    FontFamily = "EP Boxi",
    FontSize = 36,
    FontColor = "#72aeef"
}

-- Date
Config.Date = {
    FontFamily = "Young Serif",
    FontSize = 20,
    FontColor = "#ffffff"
}

-- Header
Config.Header = {
    FontFamily = "EP Boxi",
    FontSize =  16,
    FontColor = "#c587ff",
    Bold = true
}

-- Texts
Config.Text = {}
Config.Text.Label = {
    FontFamily = "Roboto Slab",
    FontSize =  12,
    FontColor = "#61bdff",
    Bold = true
}
Config.Text.Info = {
    FontFamily = "Roboto Slab",
    FontSize =  12,
    FontColor = "#9adaff",
    Bold = true
}
Config.Text.Special = {
    FontFamily = "Roboto Slab",
    FontSize =  13,
    FontColor = "#e5c9ff",
    Bold = true
}

-- Graphs
Config.LineGraph = {
    DefaultHeight = 50,
    HistoryCount = 60,
    Background = "#00000040",
    Graph = {
        LineColor = "#00FF00",
        LineWidth = 1,
        Background = "#FFFF0040",
        ScaleY = 100
    },
    Border = {
        Color = "#6464ff",
        LineWidth = 1
    },
    Grid = {
        Color = "#CCCCCC30",
        LineWidth = 1,
        PartsX = 6,
        PartsY = 3
    }
}