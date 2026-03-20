#!/usr/bin/env bash
# Use provided location or default to Lahti
LOCATION="${1:-Lahti}"
# Replace spaces with +
LOCATION="${LOCATION// /+}"

# Fetch the JSON
raw_json=$(curl -s "https://wttr.in/${LOCATION}?format=j1")

# If the data is empty or just {}, show the error icon
if [[ -z "$raw_json" ]] || [[ "$raw_json" == "{}" ]]; then
    echo '{"text":"󰖪","tooltip":"Weather Offline"}'
    exit 0
fi

# Correct JQ path: .current_condition
echo "$raw_json" | jq -c '
  if .current_condition == null then
    {"text":"󰖪","tooltip":"Weather Data Missing"}
  else
    .current_condition[0] as $c |
    {
      "113":"☀️","116":"⛅","119":"☁️","122":"☁️",
      "143":"🌫️","176":"🌦️","179":"🌨️","182":"🌧️",
      "185":"🌧️","200":"⛈️","227":"🌨️","230":"❄️",
      "248":"🌫️","260":"🌫️","263":"🌦️","266":"🌦️",
      "281":"🌧️","284":"🌧️","293":"🌦️","296":"🌧️",
      "299":"🌧️","302":"🌧️","305":"🌧️","308":"🌧️",
      "311":"🌧️","314":"🌧️","317":"🌧️","320":"🌨️",
      "323":"🌨️","326":"🌨️","329":"🌨️","332":"🌨️",
      "335":"❄️","338":"❄️","350":"🌨️","353":"🌦️",
      "356":"🌧️","359":"🌧️","362":"🌧️","365":"🌧️",
      "368":"🌨️","371":"❄️","374":"🌨️","377":"🌨️",
      "386":"⛈️","389":"⛈️","392":"⛈️","395":"⛈️"
    } as $icons |
    ($icons[$c.weatherCode] // "🌡️") as $icon |
    {
      "text": "\($icon) \($c.temp_C)°C",
      "tooltip": "\($icon) \($c.weatherDesc[0].value)\nTemp: \($c.temp_C)°C\nFeels like: \($c.FeelsLikeC)°C"
    }
  end
'
