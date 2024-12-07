local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local weather = sbar.add("item", "widgets.weather", {
  position = "right",
  icon = { drawing = false },
  label = {
    string = icons.loading,
    font = { family = settings.font.numbers }
  },
  update_freq = 900,
  popup = { align = "center", height = 25 }
})

sbar.add("bracket", "widgets.weather.bracket", { weather.name }, {
  background = { color = colors.bg1 }
})

sbar.add("item", "widgets.weather.padding", {
  position = "right",
  width = settings.group_paddings
})

local popup_days = {}
for i = 1, 3 do
    local popup_hours = {}
    local item = sbar.add("item", {
        position = "popup." .. weather.name,
        label = {
          string = "?",
          width = 160,
          align = "left"
        }
      })
    for j = 1, 8 do
        local hour_item = sbar.add("item", {
            position = "popup." .. weather.name,
            icon = {
              string = "?",
              width = 25,
              align = "left"
            },
            label = {
              string = "?",
              width = 135,
              align = "left"
            }
          })
        table.insert(popup_hours, hour_item)
    end
    local popup_value = {
        day_value = item,
        hour_values = popup_hours
    }
    table.insert(popup_days, popup_value)
end

local function map_condition_to_icon(cond)
    local condition = cond:lower():match("^%s*(.-)%s*$")
    if condition == "sunny" then
        return icons.weather.sunny
    elseif condition == "cloudy" or condition == "overcast" then
        return icons.weather.cloudy
    elseif condition == "clear" then
        return icons.weather.clear
    elseif string.find(condition, "storm") then
        return icons.weather.stormy
    elseif string.find(condition, "partly") then
        return icons.weather.partly
    elseif string.find(condition, "rain") then
        return icons.weather.rainy
    elseif string.find(condition, "snow") then
        return icons.weather.snowy
    elseif string.find(condition, "mist") or string.find(condition, "fog") then
        return icons.weather.foggy
    end
    return "?"
end

local function map_time_to_string(minutes)
    local hours = math.floor(tonumber(minutes) / 100)
    local mins = minutes % 100

    local suffix = "AM"
    if hours >= 12 then
        suffix = "PM"
        if hours > 12 then
            hours = hours - 12
        end
    end

    if minutes == "0" then
        return "12:00 AM"
    end

    local formatted_time = string.format("%2d:%02d %s", hours, mins, suffix)
    return formatted_time
end

weather:subscribe({ "routine", "forced", "system_woke" }, function(env)
    sbar.exec("curl \"wttr.in/?format=j1\"", function(weather_data)
        local current_condition = weather_data.current_condition[1]
        local temperature = current_condition.temp_F .. "°"
        local condition = current_condition.weatherDesc[1].value
        weather:set({
            icon = { string = map_condition_to_icon(condition), drawing = true },
            label = { string = temperature }
        })
        local current_time = os.date("*t")
        local time_number = current_time.hour * 100 + current_time.min
        for day_index, day_item in pairs(weather_data.weather) do
            local display_date = "Today"
            if day_index == 2 then
                display_date = "Tomorrow"
            elseif day_index == 3 then
                local two_days_later = os.time() + (2 * 24 * 60 * 60)
                display_date = tostring(os.date("%A", two_days_later))
            end
            popup_days[day_index].day_value:set({ label = { string = display_date } })
            for hourly_index, hourly_item in ipairs(day_item.hourly) do
                if day_index == 1 and time_number > tonumber(hourly_item.time) + 300 then
                    popup_days[day_index].hour_values[hourly_index]:set({
                        drawing = false
                    })
                else
                    popup_days[day_index].hour_values[hourly_index]:set({
                        icon = { string = map_condition_to_icon(hourly_item.weatherDesc[1].value) },
                        label = { string = map_time_to_string(hourly_item.time) .. " | " .. hourly_item.tempF .. "°" .. " | " .. hourly_item.chanceofrain .. "%" }
                    })
                end
            end
        end
    end)
  end)

weather:subscribe("mouse.clicked", function(env)
    weather:set({ popup = { drawing = "toggle" }})
end)

weather:subscribe("mouse.exited.global", function(env)
    weather:set({ popup = { drawing = false }})
end)