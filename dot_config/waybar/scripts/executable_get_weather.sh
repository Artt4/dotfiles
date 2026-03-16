#!/usr/bin/env bash
LOCATION="${1:-Lahti}"

raw_json=$(curl -s -m 10 -H "User-Agent: curl" "https://wttr.in/${LOCATION}?format=j1")

if [[ $? -eq 0 ]] && echo "$raw_json" | jq -e . >/dev/null 2>&1; then
    echo "$raw_json" | jq -c '
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
        text: "\($icon) \($c.temp_C)°C",
        tooltip: "\($icon) \($c.weatherDesc[0].value)\nTemp: \($c.temp_C)°C | Feels like: \($c.FeelsLikeC)°C\nHumidity: \($c.humidity)%\nWind: \($c.windspeedKmph) km/h \($c.winddir16Point)"
      }
    '
else
    echo '{"text":"󰖪 ","tooltip":"Weather Unavailable"}'
fi
