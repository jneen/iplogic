describe CIDR do
  it "parses an IP-ish and netmask-ish" do
    r = CIDR['4.33.222.111', '255.255.240.0']
    assert { r.is_a? CIDR }
    assert { r.inspect.include? '4.33.222.111/20' }

    r = CIDR[IP['4.33.222.111'], 20]
    assert { r.is_a? CIDR }
    assert { r.inspect.include? '4.33.222.111/20' }

    r = CIDR['4.33.222.111', IP['255.255.240.0']]
    assert { r.is_a? CIDR }
    assert { r.inspect.include? '4.33.222.111/20' }
  end

  it "parses slash notation" do
    r = CIDR['11.22.33.44/8']
    assert { r.is_a? CIDR }
    assert { r.inspect.include? '11.22.33.44/8' }
  end

  it "parses slash notation with a netmask" do
    r = CIDR['11.22.33.44/255.255.255.0']
    assert { r.ip.is_a? IP }
    assert { r.ip.to_s == '11.22.33.44' }
    assert { r.bits == 24 }
    assert { r.netmask == '255.255.255.0' }
  end

  it "parses shortened slash notation" do
    r = CIDR['11.22.33/24']
    assert { r.ip.is_a? IP }
    assert { r.ip.to_s == '11.22.33.0' }
    assert { r.bits == 24 }
    assert { r.netmask == '255.255.255.0' }
  end

  it "parses shortened slash notation with a netmask" do
    r = CIDR['11.22/255.255.0.0']
    assert { r.ip.is_a? IP }
    assert { r.ip.to_s == '11.22.0.0' }
    assert { r.bits == 16 }
    assert { r.netmask == '255.255.0.0' }
  end

  it "supports wrapping" do
    r = CIDR['11.22.33.44/24']
    wrapped = CIDR[r]
    assert { wrapped.is_a? CIDR }
    assert { r.object_id == wrapped.object_id }
  end

  it "fetches a random CIDR" do
    assert { CIDR.rand.is_a? CIDR }
  end

  it "knows its bits" do
    i = rand(33)
    assert { CIDR["1.1.1.1/#{i}"].bits == i }
  end

  it "knows its ip" do
    assert { CIDR['11.22.33.44/20'].ip == IP['11.22.33.44'] }
  end

  it "knows its netmask" do
    assert { CIDR['11.22.33.44/20'].netmask == IP['255.255.240.0'] }
    assert { CIDR['11.22.33.44/8'].netmask == IP['255.0.0.0'] }
    assert { CIDR['11.22.33.44/32'].netmask == IP['255.255.255.255'] }
    assert { CIDR['1.1.1.1/0'].netmask == IP['0.0.0.0'] }
  end

  it "knows its min" do
    assert { CIDR['11.22.33.44/20'].min == IP['11.22.32.0'] }
    assert { CIDR['11.22.33.44/8'].min == IP['11.0.0.0'] }
    assert { CIDR['11.22.33.44/32'].min == IP['11.22.33.44'] }
    assert { CIDR['11.22.33.44/0'].min == IP['0.0.0.0'] }
  end

  it "knows its max" do
    assert { CIDR['11.22.33.44/20'].max == IP['11.22.47.255'] }
    assert { CIDR['11.22.33.44/8'].max == IP['11.255.255.255'] }
    assert { CIDR['11.22.33.44/32'].max == IP['11.22.33.44'] }
    assert { CIDR['11.22.33.44/0'].max == IP['255.255.255.255'] }
  end

  it "knows its rest field" do
    assert { CIDR['11.22.33.44/20'].rest_field == IP['0.0.1.44'] }
    assert { CIDR['11.22.33.44/8'].rest_field == IP['0.22.33.44'] }
    assert { CIDR['11.22.33.44/32'].rest_field == IP['0.0.0.0'] }
    assert { CIDR['11.22.33.44/0'].rest_field == IP['11.22.33.44'] }
  end

  it "knows its size" do
    assert { CIDR['11.22.33.44/20'].size == 0x1000 }
    assert { CIDR['11.22.33.44/8'].size == 0x1000000 }
    assert { CIDR['11.22.33.44/32'].size == 1 }
    assert { CIDR['11.22.33.44/0'].size == 0x100000000 }
  end

  it "is enumerable" do
    r = CIDR['11.22.33.44/24']
    assert { r.respond_to? :each }
    assert { CIDR.included_modules.include? Enumerable }

    a = r.to_a

    assert { a.size == r.size }
    assert { a.first == r.first }
    assert { a.last == r.last }
  end

  it "tests inclusion" do
    r = CIDR['11.22.33.44/24']
    assert { r.respond_to? :include? }
    assert { r.include? '11.22.33.0' }
    assert { r.include? IP['11.22.33.255'] }
    deny { r.include? IP['11.22.32.44'].to_i }
    deny { r.include? '11.22.34.44' }
  end

end
