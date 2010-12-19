require File.join(File.dirname(__FILE__), 'spec_helper')

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
