Config = {}

-- Videocard
Config.VideoCard = "AMD Radeon RX 7800 XT"

-- Partitions
Config.Partitions = {
    "/",
    "/home",
    "/mnt/zusatz"
}

-- Network interface
Config.Network = {}
Config.Network.Interface = "enp0s31f6"
Config.Network.DownloadMaxBytePerSecond = 14417920
Config.Network.UploadMaxBytesPerSecond = 4063232

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
    FontSize = 18,
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
Config.Text.Large = {
    FontFamily = "Roboto Slab",
    FontSize =  14,
    FontColor = "#9adaff",
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
        Scale = 100
    },
    Border = {
        Color = "#6495ff",
        LineWidth = 1
    },
    Grid = {
        Color = "#CCCCCC30",
        LineWidth = 1,
        PartsX = 6,
        PartsY = 3
    }
}

Config.PieGraph = {
    DefaultSize = 50,
    Background = "#00000060",
    PaddingPercent = 5,
    Graph = {
        Color = "#00FF00",
        EmptyColor = "#00FF0030",
        BarWidthPercent = 70,
        Scale = 100,
        PaddingPercent = 5,
        Label = {
            FontFamily = "Roboto Slab",
            FontSize =  12,
            FontColor = "#00FF00"
        }
    },
    Border = {
        Color = "#007000",
        LineWidth = 1
    },
    Grid = {
        Color = "#CCCCCC30",
        LineWidth = 1,
        PartsX = 5,
    }
}

Config.BarGraph = {
    DefaultHeight = 10,
    Background = "#00000060",
    Graph = {
        Color = "#008300",
        Scale = 100
    },
    Border = {
        Color = "#6495ff",
        LineWidth = 1
    },
    Grid = {
        Color = "#CCCCCC30",
        LineWidth = 1,
        PartsX = 5
    }
}

Config.NetworkGraph = {
    Download = {
        LineColor = "#ecd400",
        LineWidth = 1,
        Background = "#ecd40040",
        Scale = Config.Network.DownloadMaxBytePerSecond
    },
    Upload = {
        LineColor = "#005be8",
        LineWidth = 1,
        Background = "#005be840",
        Scale = Config.Network.UploadMaxBytesPerSecond
    }
}
