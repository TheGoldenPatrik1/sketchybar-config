# SketchyBar Config

This repository is my personal configuration for [SketchyBar](https://github.com/FelixKratz/SketchyBar), a macOS plugin to customize the top menu bar. My configuration is largely derived from and built upon [this repository](https://github.com/FelixKratz/dotfiles).

![SketchyBar Config Appearance](demo.png)

## Notable Enhancements

In addition to possessing all the features of the aforementioned configuration, this also offers the following improvements:

- **Battery Health** information, displayed when the Battery Widget is clicked.
- Redesigned **Calendar Widget** that takes up less space and opens Calendar when clicked.
- **Clipboard Widget** that displays up to five of your last copied items. Clicking an item re-copies it.
- Support for a **JSON Configuration File** to customize various aspects of the bar.
- Improved **Media Widget**, with superior play/pause functionality.
- **RAM Widget** that displays the current RAM utilization, along with a graph.
- **Settings Widget** to refresh SketchyBar, quit SketchyBar, open the configuration file in VSCode, or upgrade to the latest version.
- **Stock Widget** that displays current stock trends, with 1D, 5D, and 1M data.
- **VPN Icon** that displays on the **Wifi Widget**, when a connected to a VPN.
- **Weather Widget** that displays current temperature and conditions, with a pop-up menu displaying semi-hourly forecast for the next two days.

## Installation

1. Install [Homebrew](https://brew.sh/).

2. Install [Luarocks](https://luarocks.org/):

```bash
brew install luarocks
```

3. Install [Lunajson](https://github.com/grafi-tt/lunajson):

```bash
sudo luarocks install lunajson
```

4. Install [yfinance](https://pypi.org/project/yfinance/).

5. Run the following script to clone this repository and install dependencies. Note: you may need to run the script twice for everything to install properly.

```bash
sudo curl -L https://raw.githubusercontent.com/TheGoldenPatrik1/sketchybar-config/main/scripts/install.sh | sh
```

6. Restart SketchyBar:

```
brew services restart sketchybar
```

7. Go to "Settings" -> "Control Center" -> "Automatically hide and show the menu bar" and change its value to "Always."

**Note**: to get the most out of this configuration, it is also recommended to install [yabai](https://github.com/koekeishiya/yabai).

## Configuration

The default configuration values are defined in full [here](settings.lua). You may overwrite any or all of them by creating a `config.json` file in the root directory of the project.

**A note about the weather**: The Weather Widget draws from [wttr.in](https://github.com/chubin/wttr.in), which automatically determines your location based on IP address. However, their IP-to-location mapping mechanism is unreliable, especially when using a VPN. To recieve accurate location-based weather data, it may be advisable to configure one of the weather-related options below.

| Name | Type | Default | Description |
| ---- | ---- | ---- | ---- |
| `bar_height` | `integer` | `40` | The height of the bar. |
| `calendar.click_script` | `string` | `open -a Calendar` | Script to run when the Calendar Widget gets clicked. |
| `clipboard.max_items` | `integer` | `5` | Number of items to save in the Clipboard Widget. |
| `font` | `object` | [helpers/default_font.lua](helpers/default_font.lua) | Font configuration. |
| `group_paddings` | `integer` | `5` | Padding used to separate groups in the bar. |
| `hide_widgets` | `array` | `[]` | List of widget names that you want hidden from the bar. |
| `icons` | `string` | `sf-symbols` | Icon library to use; other option is `NerdFont`. |
| `paddings` | `integer` | `3` | Padding used throughout the bar. |
| `python_command` | `string` | `python` | Command to use to run Python. The shell environment that SketchyBar uses to execute commands is a bit minimal, so you may need to specify an absolute path to your Python version of choice. |
| `stocks.default_symbol` | `object` | `{ "symbol": "^GSPC", "name": "S&P 500" }` | The default stock symbol to track and show on the Stock Widget. |
| `stocks.symbols` | `array` | `[ {"symbol": "^DJI", "name": "Dow"}, {"symbol": "^IXIC", "name": "Nasdaq"}, {"symbol": "^RUT", "name": "Russell 2K"} ]` | Stock symbols to track and show on the Stock Widget's popup menu. For each item, you must provide a `symbol` but you do not have to provide a `name`. |
| `weather.location` | `string` | N/A | Default location used to pass to [wttr.in](https://github.com/chubin/wttr.in). You can use any data that wttr.in accepts, but, in the United States, best results are usually achieved with `City+State` where `State` is the full name of the state and not an abbrevation (e.g., `Chicago+Illinois`). |
| `weather.use_shortcut` | `boolean` | `false` | Whether to try to run [this simple shortcut](https://www.icloud.com/shortcuts/6d1018c04fe2490cb241425d8f133e0c) find your location to pass to wttr.in. You must install the shortcut first. |
