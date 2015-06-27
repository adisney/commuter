require 'json'
require 'time'

def get_rain_data
  next_hour = []
  open('./next_hour.json') do |f|
    f.readlines.map do |line|
      next_hour << JSON.parse(line, :symbolize_names => true)
    end
  end
  return next_hour
end

class Commuter

  def calculate_starttages(next_hour)
    starttages = []
    starttage = []
    next_hour.each do |m|
      if will_rain(m)
        starttage << m[:intensity]
      elsif !starttage.empty?
        starttages << starttage
        starttage = []
      end
    end
    starttages << starttage if !starttage.empty?
    starttages 
  end

  def calculate_stoppages(next_hour, start_of_rain)
    stoppages = []
    stoppage = []
    next_hour.slice(next_hour.find_index(start_of_rain), next_hour.length).each do |m|
      if !will_rain(m)
        stoppage << m[:time]
      elsif !stoppage.empty?
        stoppages << [stoppage.first, stoppage.last]
        stoppage = []
      end
    end
    stoppages << [stoppage.first, stoppage.last] if !stoppage.empty?
    stoppages
  end

  def now()
    Time.new.strftime('%s%3N').to_i
  end

  def time_diff(start, stop)
    (stop - start) / 1000 / 60
  end

  def intensity(intensity, type = "")
    string = ""
    if intensity < 0.002
      string = "no"
    elsif intensity < 0.017
      string = "light"
    elsif intensity < 0.1
      string = "moderate"
    else  
      string = "heavy"
    end
    "#{string}#{type.empty? ? "" : (" " + type)}"
  end

  def will_rain(m)
    m[:probability] >= 0.75
  end

  def stoppage_report(stoppages)
    if !stoppages.empty?
      return " Stopping in #{time_diff(now, stoppages.first[0])} minutes for #{time_diff(stoppages.first[0], stoppages.first[1])} minutes."
    else
      return " Not forecast to stop by hours end."
    end
  end

  def rain_report(next_hour, is_raining, start_of_rain)
    if is_raining
      return "Currently #{intensity(next_hour.first[:intensity], next_hour.first[:type])}"
    elsif start_of_rain
      return "#{intensity(start_of_rain[:intensity], start_of_rain[:type]).capitalize} in #{time_diff(now, start_of_rain[:time])} minutes"
    end
  end

  def turning_to(starttages)
    if (starttages)
      "Turning to #{intensity(starttages.first.max)}."
    end
  end

  def produce_report(next_hour)
    #{time: (.time * 1000), probability: .precipProbability, intensity: .precipIntensity, type: .precipType}
    probabilities = next_hour.map { |m| m[:probability] }

    is_raining = probabilities[0] >= 0.9 
    start_of_rain = (next_hour.select { |m| will_rain(m) }).first

    if is_raining || start_of_rain
      starttages = calculate_starttages(next_hour)
      stoppages = calculate_stoppages(next_hour, start_of_rain)

      return "#{rain_report(next_hour, is_raining, start_of_rain)}. #{turning_to(starttages)}#{stoppage_report(stoppages)}"
    end
  end
end

STDOUT.puts Commuter.new.produce_report get_rain_data
