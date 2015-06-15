#!/bin/bash

export PATH=PATH:/bin:/usr/local/bin:/usr/bin
root_dir=`dirname $0`

curl -s https://api.forecast.io/forecast/ebeafc5205b1cbee693b9089968d9ece/41.9036,-87.6733 | jq -c ".minutely.data[] | {time: (.time * 1000), probability: .precipProbability, intensity: .precipIntensity, type: .precipType}" > next_hour.json
cp next_hour.json $root_dir/next_hour_`date +%s`.json

curl -s -F "token=aXUVVTYmcpghSgGeCAVNxcXkXFM9fB" -F "user=uah7sDAHUfvaju3S4WvALuQK2fq5H5" https://api.pushover.net/1/messages.json -F "message=`ruby $root_dir/commuter.rb next_hour.json`"
printf "\n"
