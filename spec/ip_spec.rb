describe IP do
  it "parses a string" do
    ip = IP['11.22.33.44']
    assert { ip.is_a? IP }
    assert { ip.inspect.include? '11.22.33.44' }
  end

  it "parses an integer" do
    ip = IP[255]
    assert { ip.is_a? IP }
    assert { ip.inspect.include? '0.0.0.255' }

    ip = IP[0xA00A10FF]
    assert { ip.is_a? IP }
    assert { ip.inspect.include? '160.10.16.255' }
  end

  it "parses an array of int-ish objects" do
    four = Class.new do
      def to_i
        4
      end
    end.new

    ip = IP[[7, '42', four, nil]]
    assert { ip.is_a? IP }
    assert { ip.inspect.include? '7.42.4.0' }
  end

  it "parses nil" do
    ip = IP[nil]
    assert { ip.is_a? IP }
    assert { ip.inspect.include? '0.0.0.0' }
  end

  it "parses an IP" do
    ip = IP['11.22.33.44']

    assert { IP[ip].is_a? IP }
    assert { IP[ip].object_id == ip.object_id }
  end

  it "knows its integer representation" do
    i = rand(0xFFFFFFFF)
    assert { IP[i].to_i == i }
  end

  it "knows its string representation" do
    assert { IP['11.22.33.44'].to_s == '11.22.33.44' }
  end

  it "knows its octets" do
    assert { IP['44.33.22.11'].octets == [44, 33, 22, 11] }
  end

  it "knows the max" do
    assert { IP.max.to_i == 0xFFFFFFFF }
    assert { IP.max.to_s == '255.255.255.255' }
  end

  it "fetches a random ip" do
    assert { IP.rand.is_a? IP }
  end

  it "is comparable" do
    assert { IP.included_modules.include? Comparable }

    assert { IP.public_methods.include? :<=> }

    i1, i2 = rand(0xFFFFFFFF), rand(0xFFFFFFFF)
    assert { (IP[i1] <=> IP[i2]) == (i1 <=> i2) }
  end

  it "can add, subtract, and succ" do
    i1, i2 = rand(0xFFFFFFF), rand(0xFFFFFFF)
    ip1 = IP[i1]
    ipsum = IP[i1] + i2
    assert { ipsum.is_a? IP }
    assert { ipsum.to_i == i1 + i2 }

    assert { ip1.succ.to_i == i1 + 1 }
    assert { (ipsum - i2).to_i == i1 }
    assert { (ipsum - ip1).to_i == i2 }
  end

  it "knows its prefix and rest field given a netmask" do
    ip = IP['11.22.33.44']

    assert { ip.prefix('255.255.255.0') == IP['11.22.33.00'] }
    assert { ip.rest_field('255.255.255.0') == IP['0.0.0.44'] }
    assert {
      (ip.prefix('255.255.255.0') + ip.rest_field('255.255.255.0')) == ip
    }

    assert { ip.prefix('255.255.240.0') == IP['11.22.32.00'] }
    assert { ip.rest_field('255.255.240.0') == IP['0.0.1.44'] }
    assert {
      (ip.prefix('255.255.240.0') + ip.rest_field('255.255.240.0')) == ip
    }
  end

  it "knows whether it's a netmask" do
    zero_bits = rand(32)
    (0..32).each do |bits|
      assert { IP[(0xFFFFFFFF >> bits) << bits].netmask? }
    end

    deny { IP['1.2.3.4'].netmask? }
    deny { IP['0.255.0.0'].netmask? }
  end
end
