function safe_config(config, testconfig)
    local ret = table_copy(config)
    if testconfig == nil then
        testconfig = test_config
    end

    for k,v in pairs(testconfig) do
        if config[k] == nil then
            ret[k] = testconfig[k]
        elseif type(v) == "table" then
            ret[k] = safe_config(config[k], v)
        end
    end

    return ret
end

test_config = {
    Language = "en",
    MarginY = 10,
    MarginX = 5,
    Padding = 3,
    Header = {
        FontFamily = "EP Boxi",
        FontSize =  16,
        FontColor = "#c587ff",
        Bold = true
    },

    Text = {
        Label = {
            FontFamily = "Roboto Slab",
            FontSize =  12,
            FontColor = "#61bdff",
            Bold = true
        },
        Info = {
            FontFamily = "Roboto Slab",
            FontSize =  12,
            FontColor = "#9adaff",
            Bold = true
        },
        Special = {
            FontFamily = "Roboto Slab",
            FontSize =  13,
            FontColor = "#e5c9ff",
            Bold = true
        },
        Large = {
            FontFamily = "Roboto Slab",
            FontSize =  14,
            FontColor = "#9adaff",
        }
    },

    LineGraph = {
        HistoryCount = 120,
        Graph = {
            Scale = 100
        },
        Border = {},
        Grid = {}
    },

    PieGraph = {
        PaddingPercent = 0,
        Graph = {
            BarWidthPercent = 50,
            Label = {}
        },
        Border = {},
        Grid = {}
    },

    BarGraph = {
        Graph = {},
        Border = {},
        Grid = {}
    }
}