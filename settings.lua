local lunajson = require 'lunajson'

local file = require("utils.file")
local tbl = require("utils.tbl")

local function load_config()
    local config = {
        bar_height = 40,
        calendar = {
            click_script = "open -a Calendar"
        },
        clipboard = {
            max_items = 5
        },
        font = require("helpers.default_font"), -- This is a font configuration for SF Pro and SF Mono (installed manually)
        -- Alternatively, this is a font config for JetBrainsMono Nerd Font
        -- font = {
        --   text = "JetBrainsMono Nerd Font", -- Used for text
        --   numbers = "JetBrainsMono Nerd Font", -- Used for numbers
        --   style_map = {
        --     ["Regular"] = "Regular",
        --     ["Semibold"] = "Medium",
        --     ["Bold"] = "SemiBold",
        --     ["Heavy"] = "Bold",
        --     ["Black"] = "ExtraBold",
        --   },
        -- },
        group_paddings = 5,
        hide_widgets = {},
        icons = "sf-symbols", -- alternatively available: NerdFont
        paddings = 3,
        python_command = "python",
        stocks = {
            default_symbol = { symbol = "^GSPC", name = "S&P 500" },
            symbols = {
                { symbol = "^DJI", name = "Dow" },
                { symbol = "^IXIC", name = "Nasdaq" },
                { symbol = "^RUT", name = "Russell 2K" }
            }
        },
        weather = {
            location = false,
            use_shortcut = false
        }
    }

    local config_filepath = os.getenv("CONFIG_DIR") .. "/config.json"
    local content, error = file.read(config_filepath)
    if not error then
        local json_content = lunajson.decode(content)
        tbl.merge(config, json_content)
    end
    return config
end

return load_config()
