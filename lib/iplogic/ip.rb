module IPLogic
  class IP
    class << self
      # Basic idempotent wrapper for creating addresses.
      #
      # @param [String, Fixnum, Array, nil]
      # @return [IP] the wrapped IP address
      #
      # @example
      #   >> IP['11.22.33.44']
      #   => #<IP [ 11.22.33.44 ]>
      #
      # @example
      #   >> IP[0xFFFFFFFF]
      #   => #<IP [ 255.255.255.255 ]>
      #
      # @example
      #   >> IP[nil]
      #   =>  #<IP [ 0.0.0.0 ]>
      #
      # @example
      #   >> IP(['11', 22, 33, '44'])
      #   => #<IP [ 11.22.33.44 ]>
      #
      # @example
      #   >> ip = IP['11.22.33.44']
      #   => #<IP [ 11.22.33.44 ]>
      #   >> IP(ip)
      #   => #<IP [ 11.22.33.44 ]>
      #   >> ip.object_id == IP[ip].object_id
      #   => true
      def wrap(arg)
        return arg if arg.is_a? IP

        int = case arg
        when Array
          octets_to_int(arg)
        when String
          octets_to_int(arg.split('.'))
        when Fixnum
          arg
        when nil
          0
        else
          raise FormatError, "IP: Unable to parse #{arg.inspect}"
        end

        unless (0..0xFFFFFFFF).include? int
          raise FormatError, "IP: Address #{arg.inspect} out of range"
        end

        return new(int)
      end

      alias [] wrap

      FormatError = Class.new(ArgumentError)

      # @return [IP] a random IP address.  Useful for mocks / tests
      def rand
        wrap(Kernel.rand(0x100000000))
      end

    private
      def octets_to_int(octets)
        r = 0
        octets.reverse.each_with_index do |octet, i|
          r += (octet.to_i << 8*i)
        end
        r
      end
    end

    # -*- instance methods -*-

    # Get the integer representation of this IP address
    # @return [Integer]
    attr_reader :int
    alias to_i int

    # an IP can be used anywhere an integer can
    alias to_int int

    def initialize(int, extra={})
      @int = int
    end

    MAXIP = IP.new(0xFFFFFFFF)
    # @return [IP] The maximum IP address: 255.255.255.255
    def self.max
      MAXIP
    end

    # @return [Array] an array of the four octets.
    #
    # @example
    #   IP['1.2.3.4'].octets # => [1, 2, 3, 4]
    def octets
      @octets ||= begin
        rad = int.radix(256)
        [0]*([4-rad.size,0].max) + rad
      end
    end
    alias parts octets

    # @return [String] the usual string representation of the ip address.
    def to_s
      octets.join('.')
    end

    def inspect
      "#<IP [ #{self} ]>"
    end

    # an IP uses its string representation as its hash
    # @return [String]
    def hash
      self.to_s.hash
    end

    def eql?(other)
      self.int == IP.wrap(other).int
    end
    alias == eql?

    include Comparable
    # IP addresses are ordered in the usual way
    def <=>(other)
      self.int <=> other.int
    end

    # @param [#to_i] int_ish the amount to add
    # @return [IP] the result of adding int_ish to the underlying integer
    def +(int_ish)
      IP.wrap(int + int_ish.to_i)
    end

    # @param [#to_i] int_ish the amount to subtract
    # @return [IP] the result of subtracting int_ish from the underlying integer
    def -(int_ish)
      self + (-int_ish.to_i)
    end

    # This allows IP "ranges" with (ip1..ip2)
    # @return [IP]
    def succ
      self + 1
    end

    # given a netmask, returns the network prefix.
    #
    # @return [IP] the network prefix
    #
    # @example
    #   IP['1.2.3.4'].prefix('255.255.0.0') # => #<IP [ 1.2.0.0 ]>
    def prefix(netmask)
      CIDR.wrap(self, netmask).min
    end
    alias min prefix

    def max(netmask)
      CIDR.wrap(self, netmask).max
    end

    # given a netmask, returns the "rest field" - the bits
    # not covered by the netmask.  See CIDR#rest_field.
    #
    #     IP['1.2.3.4'].rest_field # => #<IP [ 0.0.3.4 ]>
    #
    # @return [IP] the rest field
    # @see CIDR#rest_field
    def rest_field(netmask)
      CIDR.wrap(self, netmask).rest_field
    end
    alias rest rest_field

    # test if this IP address is a valid netmask.
    def netmask?
      maxint32 = 0xFFFFFFFF
      (0..32).any? do |i|
        (int-1) + (1 << i) == maxint32
      end
    end

    # raises an error unless this IP address is a valid netmask.
    def assert_netmask!
      raise ArgumentError, <<-msg.strip unless netmask?
        #{self.inspect} is not a valid netmask.
      msg
    end
  end
end
