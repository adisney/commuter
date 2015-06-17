require 'commuter'

describe "commuter" do
  it "should report intensity" do
    expect(intensity(0, "rain")).to eq "no rain"
    expect(intensity(0.002, "rain")).to eq "light rain"
    expect(intensity(0.017, "rain")).to eq "moderate rain"
    expect(intensity(0.1, "rain")).to eq "heavy rain"
  end

  it "will rain if above certain probability" do
    expect(will_rain({probability: 0.75})). to be_truthy
  end
end
