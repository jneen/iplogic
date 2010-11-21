require 'spec_helper'

describe "Radix" do
  before :each do
    @lim = 50 + rand(100)
    @rad = 2 + rand(9)
  end

  it "calculates radix" do
    (1..@lim).each do |i|
      i.radix(@rad).join.should == i.to_s(@rad)
    end
  end
end
