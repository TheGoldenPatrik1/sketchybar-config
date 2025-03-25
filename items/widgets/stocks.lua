local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local tbl = require("utils.tbl")
local file = require("utils.file")
local lunajson = require("lunajson")

local default_symbol = tbl.copy(settings.stocks.default_symbol)
local symbols = tbl.copy(settings.stocks.symbols)
local data_key = "today"
local loading = false
local refresh_popup

local stocks_up = sbar.add("item", "widgets.stocks1", {
    position = "right",
    padding_left = 0,
    width = 0,
    icon = { drawing = false },
    label = {
        drawing = false,
        font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Bold"],
            size = 8.0,
        }
    },
    y_offset = 5
})

local stocks_down = sbar.add("item", "widgets.stocks2", {
    position = "right",
    padding_left = 0,
    icon = { drawing = false },
    label = {
        drawing = false,
        font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Bold"],
            size = 10.0,
        }
    },
    y_offset = -4,
})

local stocks = sbar.add("item", "widgets.stocks.padding", {
    position = "right",
    icon = {
        string = icons.loading,
        font = { family = settings.font.numbers }
    },
    label = { drawing = false },
    update_freq = 600,
    popup = { align = "center", height = 25 }
})

sbar.add("bracket", "widgets.stocks.bracket", { stocks.name, stocks_up.name, stocks_down.name }, {
    background = { color = colors.bg1 }
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local stock_popups = {}
for i, _ in ipairs(symbols) do
    local popup = sbar.add("item", "stocks.popup" .. i, {
        position = "popup." .. stocks.name,
        label = {
            string = "No data",
            width = 120,
            align = "left",
            font = { size = 12.0 }
        },
        drawing = true
    })
    table.insert(stock_popups, popup)
end

local function get_stock_info(percent_change)
    local percent_change_str = string.format("%.2f%%", math.abs(percent_change))
    local icon
    if percent_change_str == "0.00%" then
        icon = { string = icons.stocks.even, color = colors.white }
    else
        local icon_value = percent_change > 0 and icons.stocks.up or icons.stocks.down
        local icon_color = percent_change > 0 and colors.green or colors.red
        icon = { string = icon_value, color = icon_color }
    end
    return icon, { string = percent_change_str, drawing = true }
end

local function load_stocks()
    local json_encoded = file.read(os.getenv("CONFIG_DIR") .. "/data/stock_data.json")
    local stock_data = lunajson.decode(json_encoded)

    local percent_change = stock_data[default_symbol.symbol]
    local icon, label = get_stock_info(percent_change[data_key])
    
    stocks_up:set({ label = { string = default_symbol.name or default_symbol.symbol, drawing = true } })
    stocks:set({ icon = icon })
    stocks_down:set({ label = label })

    for i, value in ipairs(symbols) do
        percent_change = stock_data[value.symbol][data_key]
        icon, label = get_stock_info(percent_change)
        stock_popups[i]:set({
            icon = icon,
            label = { string = (value.name or value.symbol) .. " " .. label.string, align = "left" }
        })
        stock_popups[i]:subscribe("mouse.clicked", function ()
            stocks:set({ popup = { drawing = false } })
            table.insert(symbols, default_symbol)
            default_symbol = value
            table.remove(symbols, i)
            load_stocks()
        end)
    end
    loading = false
    refresh_popup:set({ label = { string = "Refresh" } })
end

local toggle_keys = {"today", "five_days", "month"}
local toggle_values = {"Switch to 1D", "Switch to 5D", "Switch to 1M"}
local toggle_popups = {}
for i = 1, 3 do
    local key = toggle_keys[i]
    local toggle_data_popup = sbar.add("item", "stocks.popup" .. #stock_popups + i, {
        position = "popup." .. stocks.name,
        label = {
            string = toggle_values[i],
            width = 120,
            align = "left",
            font = { size = 12.0 }
        },
        drawing = i ~= 1
    })
    toggle_data_popup:subscribe("mouse.clicked", function ()
        toggle_popups[tbl.get_index_by_value(toggle_keys, data_key)]:set({ drawing = true })
        data_key = key
        toggle_data_popup:set({ drawing = false })
        load_stocks()
    end)
    table.insert(toggle_popups, toggle_data_popup)
end

refresh_popup = sbar.add("item", "stocks.popup" .. #stock_popups + 3 + 1, {
    position = "popup." .. stocks.name,
    label = {
        string = "Refresh",
        width = 120,
        align = "left",
        font = { size = 12.0 }
    },
    drawing = true
})

local function pull_stock_data()
    if loading then return end
    loading = true
    refresh_popup:set({ label = { string = "Loading..." } })
    local symbol_table = {}
    for _, value in ipairs(settings.stocks.symbols) do
        table.insert(symbol_table, value.symbol)
    end
    table.insert(symbol_table, settings.stocks.default_symbol.symbol)
    local symbols_string = table.concat(symbol_table, " ")
    sbar.exec(
        settings.python_command .. " $CONFIG_DIR/helpers/stocks.py $CONFIG_DIR " .. symbols_string,
        load_stocks
    )
end

refresh_popup:subscribe("mouse.clicked", pull_stock_data)
stocks:subscribe({"routine", "forced", "system_woke"}, function()
    loading = false
    pull_stock_data()
end)

local function show_popup()
    stocks:set({ popup = { drawing = "toggle" } })
end

local function hide_popup()
    stocks:set({ popup = { drawing = false } })
end

stocks_up:subscribe("mouse.clicked", show_popup)
stocks_down:subscribe("mouse.clicked", show_popup)
stocks:subscribe("mouse.clicked", show_popup)
stocks:subscribe("mouse.exited.global", hide_popup)
