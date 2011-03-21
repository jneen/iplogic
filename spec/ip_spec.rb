require File.join(File.dirname(__FILE__), 'spec_helper')

describe IP do
  it "parses a string" do
    ip = IP('11.22.33.44')
    ip.should be_a IP
    ip.inspect.should include '11.22.33.44'
  end

  it "parses an integer" do
    ip = IP(255)
    ip.should be_a IP
    ip.inspect.should include '0.0.0.255'

    ip = IP(0xA00A10FF)
    ip.should be_a IP
    ip.inspect.should include '160.10.16.255'
  end

  it "parses an array of int-ish objects" do
    four = Class.new do
      def to_i
        4
      end
    end.new

    ip = IP([7, '42', four, nil])
    ip.should be_a IP
    ip.inspect.should include '7.42.4.0'
  end

  it "parses nil" do
    ip = IP(nil)
    ip.should be_a IP
    ip.inspect.should include '0.0.0.0'
  end

  it "parses an IP" do
    ip = IP('11.22.33.44')
    IP(ip).should be_a IP
    IP(ip).object_id.should == ip.object_id
  end

  it "knows its integer representation" do
    i = rand(0xFFFFFFFF)
    IP(i).to_i.should == i
  end

  it "knows its string representation" do
    IP('11.22.33.44').to_s.should == '11.22.33.44'
  end

  it "knows its parts" do
    IP('44.33.22.11').parts.should == [44, 33, 22, 11]
  end

  it "knows the max" do
    IP::MAXIP.to_i.should == 0xFFFFFFFF
    IP.max.to_i.should == 0xFFFFFFFF
    IP.max.to_s.should == '255.255.255.255'
  end

  it "fetches a random ip" do
    IP.rand.should be_a IP
  end

  it "is comparable" do
    IP.included_modules.should include Comparable
    IP.public_methods.should include '<=>'

    i1, i2 = rand(0xFFFFFFFF), rand(0xFFFFFFFF)
    (IP(i1) <=> IP(i2)).should == (i1 <=> i2)
  end

  it "can add, subtract, and succ" do
    i1, i2 = rand(0xFFFFFFF), rand(0xFFFFFFF)
    ip1 = IP(i1)
    ipsum = IP(i1) + i2
    ipsum.should be_a IP
    ipsum.to_i.should == i1 + i2

    ip1.succ.to_i.should == i1 + 1
    (ipsum - i2).to_i.should == i1
    (ipsum - ip1).to_i.should == i2
  end

  it "knows its prefix and rest field given a netmask" do
    ip = IP('11.22.33.44')

    ip.prefix('255.255.255.0').should == IP('11.22.33.00')
    ip.rest_field('255.255.255.0').should == IP('0.0.0.44')
    (ip.prefix('255.255.255.0') + ip.rest_field('255.255.255.0')).
      should == ip

    ip.prefix('255.255.240.0').should == IP('11.22.32.00')
    ip.rest_field('255.255.240.0').should == IP('0.0.1.44')
    (ip.prefix('255.255.240.0') + ip.rest_field('255.255.240.0')).
      should == ip
  end

  it "knows whether it's a netmask" do
    zero_bits = rand(32)
    (0..32).each do |bits|
      IP((0xFFFFFFFF >> bits) << bits).should be_netmask
    end

    IP('1.2.3.4').should_not be_netmask
    IP('0.255.0.0').should_not be_netmask
  end
end
