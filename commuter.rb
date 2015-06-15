require 'json'
require 'time'

#{time: (.time * 1000), probability: .precipProbability, intensity: .precipIntensity, type: .precipType}
next_hour = []
open('./next_hour.json') do |f|
  f.readlines.map do |line|
    next_hour << JSON.parse(line, :symbolize_names => true)
  end
end

probabilities = next_hour.map { |m| m[:probability] }

def calculate_stoppages(next_hour, start_of_rain)
  stoppages = []
  stoppage = []
  next_hour.slice(next_hour.find_index(start_of_rain), next_hour.length).each do |m|
    if !will_rain(m)
      stoppage << m
    elsif !stoppage.empty?
      stoppages << [stoppage.first[:time], stoppage.last[:time]]
      stoppage = []
    end
  end
  stoppages << [stoppage.first[:time], stoppage.last[:time]] if !stoppage.empty?
  stoppages
end

def now()
  Time.new.strftime('%s%3N').to_i
end

def time_diff(start, stop)
  (stop - start) / 1000 / 60
end

def intesity_to_str(intensity, type)
  string = ""
  if intensity < 0.002
    string = "No"
  elsif intensity < 0.017
    string = "Light"
  elsif intensity < 0.1
    string = "Moderate"
  else  
    string = "Heavy"
  end
  "#{string} #{type}"
end

def will_rain(m)
  m[:probability] > 0.75
end

is_raining = probabilities[0] >= 0.9 
start_of_rain = (next_hour.select { |m| will_rain(m) }).first

if is_raining || start_of_rain
  stoppages = calculate_stoppages(next_hour, start_of_rain)
end


def stoppage_str(stoppages)
  if !stoppages.empty?
    " Stopping in #{time_diff(now, stoppages.first[0])} minutes for #{time_diff(stoppages.first[0], stoppages.first[1])} minutes."
  else
    " Not forcast to stop in the next hour."
  end
end

if is_raining
  puts "Currently #{intesity_to_str(next_hour.first[:intensity], next_hour.first[:type])}. #{stoppage_str(stoppages)}"
elsif start_of_rain
  puts "#{intesity_to_str(start_of_rain[:intensity], start_of_rain[:type])} in #{time_diff(now, start_of_rain[:time])} minutes. #{stoppage_str(stoppages)}"
end
