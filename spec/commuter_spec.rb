require 'commuter'

describe "commuter" do
  let (:commuter) { Commuter.new }
  before( :each ) do
    allow(commuter).to receive(:now).and_return 1234567890000
  end

  it "should report intensity" do
    expect(commuter.intensity(0, "rain")).to eq "no rain"
    expect(commuter.intensity(0.002, "rain")).to eq "light rain"
    expect(commuter.intensity(0.017, "rain")).to eq "moderate rain"
    expect(commuter.intensity(0.1, "rain")).to eq "heavy rain"
  end

  it "will rain if above certain probability" do
    expect(commuter.will_rain({probability: 0.75})). to be_truthy
  end

  it "calculates stoppages" do
    next_hour = [{time: 1234567890000, probability: 0.80, intensity: 0.003},{time: 1234567890001, probability: 0.42, intensity: 0.003},{time: 1234567890002, probability: 0.21, intensity: 0.003},{time: 1234567890002, probability: 0.80, intensity: 0.003}]
    expect(commuter.calculate_stoppages(next_hour, next_hour[0])).to eq [[1234567890001,1234567890002]]
  end

  it "calculates starttages" do
    next_hour = [{time: 1234567890000, probability: 0.40, intensity: 0.003},{time: 1234567890001, probability: 0.42, intensity: 0.003},{time: 1234567890002, probability: 0.81, intensity: 0.003},{time: 1234567890002, probability: 0.80, intensity: 0.018}]
    expect(commuter.calculate_starttages(next_hour)).to eq [[0.003, 0.018]]
  end

  it "determines what the precipitation trends to" do
    expect(commuter.turning_to([[0.001, 0.003, 0.018, 0.018, 0.002]])). to eq "Turning to moderate."
  end

  describe "rain report" do
    it "is empty when no precipitation expected" do
      next_hour = [{time: 1234567890000, probability: 0.40, intensity: 0.003},{time: 1234567890001, probability: 0.42, intensity: 0.003},{time: 1234567890002, probability: 0.03, intensity: 0.003},{time: 1234567890002, probability: 0.03, intensity: 0.018}]
      expect(commuter.rain_report(next_hour, false, nil)).to eq nil
    end

    it "indicates when already raining" do
      next_hour = [{time: 1234567890000, probability: 0.80, intensity: 0.003, type: "rain"},{time: 1234567890001, probability: 0.82, intensity: 0.003, type: "rain"},{time: 1234567890002, probability: 0.03, intensity: 0.003, type: "rain"},{time: 1234567890002, probability: 0.03, intensity: 0.018, type: "rain"}]
      expect(commuter.rain_report(next_hour, true, next_hour.first)).to eq "Currently light rain"
    end

    it "indicates when it will rain" do
      next_hour = [{time: 1234567890000, probability: 0.40, intensity: 0.003, type: "rain"},{time: 1234567950000, probability: 0.42, intensity: 0.003, type: "rain"},{time: 1234568010002, probability: 0.83, intensity: 0.003, type: "rain"},{time: 1234568070002, probability: 0.88, intensity: 0.018, type: "rain"}]
      expect(commuter.rain_report(next_hour, false, next_hour[2])).to eq "Light rain in 2 minutes"
    end
  end

  describe "stoppages report" do
    it "should indicate when the rain will stop and for how long" do
      expect(commuter.stoppage_report([[1234568010000, 1234568070000]])).to eq " Stopping in 2 minutes for 1 minutes."
    end

    it "should indicate when not expected to stop within an hour" do
      expect(commuter.stoppage_report([])).to eq " Not forecast to stop by hours end."
    end
  end

  describe "produce report" do
    let (:next_hour) {[{time: 1234567890000, probability: 0.40, intensity: 0.003, type: "rain"},{time: 1234567950000, probability: 0.42, intensity: 0.003, type: "rain"},{time: 1234568010002, probability: 0.83, intensity: 0.003, type: "rain"},{time: 1234568070002, probability: 0.88, intensity: 0.018, type: "rain"},{time: 1234569690000, probability:0.30, intensity:0.001, type:"rain"},{time:1234570230000, probability:0.30, intensity:0.001, type:"rain"},{time:1234570290000, probability:0.80, intensity:0.018, type:"rain"}]}

    it "should report on future rain" do
      expect(commuter.produce_report(next_hour)).to eq "Light rain in 2 minutes. Turning to moderate. Stopping in 30 minutes for 9 minutes."
    end
  end
end
