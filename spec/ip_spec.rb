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

  describe CIDR do
    it "parses an IP-ish and netmask-ish" do
      r = CIDR('4.33.222.111', '255.255.240.0')
      r.should be_a CIDR
      r.inspect.should include '4.33.222.111/20'

      r = CIDR(IP('4.33.222.111'), 20)
      r.should be_a CIDR
      r.inspect.should include '4.33.222.111/20'

      r = CIDR('4.33.222.111', IP('255.255.240.0'))
      r.should be_a CIDR
      r.inspect.should include '4.33.222.111/20'
    end

    it "parses slash notation" do
      r = CIDR('11.22.33.44/8')
      r.should be_a CIDR
      r.inspect.should include '11.22.33.44/8'
    end

    it "knows its bits" do
      i = rand(33)
      CIDR("1.1.1.1/#{i}").bits.
        should == i
    end

    it "knows its ip" do
      CIDR('11.22.33.44/20').ip.
        should == IP('11.22.33.44')
    end

    it "knows its netmask" do
      CIDR('11.22.33.44/20').netmask.
        should == IP('255.255.240.0')

      CIDR('11.22.33.44/8').netmask.
        should == IP('255.0.0.0')

      CIDR('11.22.33.44/32').netmask.
        should == IP('255.255.255.255')

      CIDR('1.1.1.1/0').netmask.
        should == IP('0.0.0.0')
    end

    it "knows its min" do
      CIDR('11.22.33.44/20').min.
        should == IP('11.22.32.0')

      CIDR('11.22.33.44/8').min.
        should == IP('11.0.0.0')

      CIDR('11.22.33.44/32').min.
        should == IP('11.22.33.44')

      CIDR('11.22.33.44/0').min.
        should == IP('0.0.0.0')
    end

    it "knows its max" do
      CIDR('11.22.33.44/20').max.
        should == IP('11.22.47.255')

      CIDR('11.22.33.44/8').max.
        should == IP('11.255.255.255')

      CIDR('11.22.33.44/32').max.
        should == IP('11.22.33.44')

      CIDR('11.22.33.44/0').max.
        should == IP('255.255.255.255')
    end

    it "knows its rest field" do
      CIDR('11.22.33.44/20').rest_field.
        should == IP('0.0.1.44')

      CIDR('11.22.33.44/8').rest_field.
        should == IP('0.22.33.44')

      CIDR('11.22.33.44/32').rest_field.
        should == IP('0.0.0.0')

      CIDR('11.22.33.44/0').rest_field.
        should == IP('11.22.33.44')
    end

    it "knows its size" do
      CIDR('11.22.33.44/20').size.
        should == 0x1000

      CIDR('11.22.33.44/8').size.
        should == 0x1000000

      CIDR('11.22.33.44/32').size.
        should == 1

      CIDR('11.22.33.44/0').size.
        should == 0x100000000
    end

    it "is enumerable" do
      r = CIDR('11.22.33.44/24')
      r.should respond_to :each
      CIDR.included_modules.should include Enumerable

      a = r.to_a

      a.size.should == r.size
      a.first.should == r.first
      a.last.should == r.last
    end

    it "tests inclusion" do
      r = CIDR('11.22.33.44/24')
      r.should respond_to :include?
      r.should include '11.22.33.0'
      r.should include IP('11.22.33.255')
      r.should_not include IP('11.22.32.44').to_i
      r.should_not include '11.22.34.44'
    end

  end
end
