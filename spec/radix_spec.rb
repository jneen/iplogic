describe "Fixnum#radix" do
  let(:lim) { 50 + rand(100) }
  let(:rad) { 2 + rand(9) }

  it "calculates radix" do
    (1..lim).each do |i|
      assert { i.radix(rad).join == i.to_s(rad) }
    end
  end
end
