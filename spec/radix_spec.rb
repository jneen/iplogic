require 'spec_helper'

describe "Radix" do
  let(:lim) { 50 + rand(100) }
  let(:rad) { 2 + rand(9) }

  it "calculates radix" do
    (1..lim).each do |i|
      i.radix(rad).join.should == i.to_s(rad)
    end
  end
end
