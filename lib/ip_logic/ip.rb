require File.join(File.dirname(__FILE__), 'core_ext')

module IPLogic
  class IP
    class << self
      # Basic monad wrapper for IP addresses.
      #
      # You can pass it:
      #
      # a String
      # >> IP('11.22.33.44')
      # => #<IP [ 11.22.33.44 ]>
      #
      # an Integer
      # >> IP(0xFFFFFFFF)
      # => #<IP [ 255.255.255.255 ]>
      #
      # an Array of int-ish objects
      # >> IP(['11', 22, 33, '44'])
      # => #<IP [ 11.22.33.44 ]>
      #
      # nil
      # >> IP(nil)
      # =>  #<IP [ 0.0.0.0 ]>
      #
      # an IP
      # >> ip = IP('11.22.33.44')
      # => #<IP [ 11.22.33.44 ]>
      # >> IP(ip)
      # => #<IP [ 11.22.33.44 ]>
      # >> ip.object_id == IP(ip).object_id
      # => true
      #   
      def parse(arg)
        return arg if arg.is_a? IP

        int = case arg
        when Array
          parts_to_int(arg)
        when String
          parts_to_int(arg.split('.'))
        when Fixnum
          arg
        when nil
          0
        else
          raise ArgumentError, <<-msg.strip
            Couldn't parse #{arg.inspect} to an IP.
          msg
        end

        return new(int)
      end

    private
      def parts_to_int(parts)
        r = 0
        parts.reverse.each_with_index do |part, i|
          r += (part.to_i << 8*i)
        end
        r
      end
    end

    # -*- instance methods -*-
    attr_reader :int
    alias to_i int
    alias to_int int

    def initialize(int)
      @int = int
    end

    # 255.255.255.255
    MAXIP = self.new(0xFFFFFFFF)
    def self.max
      MAXIP
    end

    def parts
      @parts ||= begin
        rad = int.radix(256)
        [0]*([4-rad.size,0].max) + rad
      end
    end

    def to_s
      parts.join('.')
    end
    alias to_str to_s

    def inspect
      "#<IPLogic::IP [ #{self} ]>"
    end

    def eql?(other)
      self.int == IP(other).int
    end
    alias == eql?

    include Comparable
    def <=>(other)
      self.int <=> other.int
    end

    def +(int_ish)
      IP(int + int_ish.to_i)
    end

    def succ
      self + 1
    end

    def -(int_ish)
      self + (-int_ish.to_i)
    end

    def prefix(netmask)
      CIDR(self, netmask).min
    end
    alias min prefix

    def max(netmask)
      CIDR(self, netmask).max
    end

    def rest_field(netmask)
      CIDR(self, netmask).rest_field
    end
    alias rest rest_field

    def netmask?
      maxint32 = 0xFFFFFFFF
      (0..32).any? do |i|
        (int-1) + (1 << i) == maxint32
      end
    end

    def assert_netmask!
      raise ArgumentError, <<-msg.strip unless netmask?
        #{self.inspect} is not a valid netmask.
      msg
    end
  end

  def IP(*args)
    return IP if args.empty?
    IP.parse(args.first)
  end
end
