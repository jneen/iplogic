module IPLogic
  class CIDR
    include Enumerable

    # raised if bad arguments are passed to CIDR.wrap
    FormatError = Class.new(ArgumentError)

    # matches a shortened CIDR: `xxx.xxx.xxx/xx`
    SHORTENED_CIDR_REGEX = /^(\d{1,3}(\.\d{1,3}){1,3})\/(\d+)$/

    class << self
      # Where the magic happens.
      # @raise FormatError
      # @overload CIDR.wrap(cidr)
      #   @param [CIDR] cidr
      #   Returns the cidr.  Useful for typecasting.
      #   @return [CIDR] a CIDR
      # @overload CIDR.wrap(string)
      #   @param [String] string
      #   Parses `string` as a CIDR.  The following formats are accepted:
      #
      #       "#{partial_ip}/#{bits}":
      #         CIDR.wrap('11.22.33.44/16') # => #<CIDR[ 11.22.33.44/16 ]>
      #         CIDR.wrap('10.0.1/24') # => #<CIDR[ 10.0.1.0/24 ]>
      #
      #       "#{partial_ip}/#{netmask}":
      #         CIDR.wrap('11.22.33.44/255.255.0.0') # => #<CIDR[ 11.22.33.44/16 ]>
      #         CIDR.wrap('10.0.1/255.255.255.0') # => #<CIDR[ 10.0.1.0/24 ]>
      #   @return [CIDR] a CIDR
      # @overload CIDR.wrap(ip_ish, netmask_or_bits)
      #   @param [IP] ip_ish
      #     the address of the network.  Will be passed through `IP.wrap`.
      #   @param [Fixnum IP] netmask_or_bits
      #     the netmask or the number of addressable bits
      #     (the thing after the / in standard CIDR notation)
      #
      def wrap(*args)
        return args.first if args.first.is_a? CIDR
        if args.size == 2
          ip, bits = args

          bits = case bits
          when Integer
            bits
          when String, IP
            netmask_to_bits(IP.wrap(bits))
          else
            if bits.respond_to? :to_i
              bits.to_i
            else
              format_error(args, bits)
            end
          end

          ip = parse_shortened_ip(ip) if ip.is_a? String

          return new(ip, bits)

        elsif args.size == 1
          arg = args.first

          return arg if arg.is_a? CIDR

          # one argument means it's gotta be a string to parse
          format_error(arg) unless arg.is_a? String

          if arg =~ SHORTENED_CIDR_REGEX
            new(parse_shortened_ip($1), $3)
          elsif (octets = arg.split('/')).size == 2
            ip = parse_shortened_ip(octets[0])
            mask = IP.wrap(octets[1])
            return new(ip, netmask_to_bits(mask))
          else
            format_error(arg)
          end
        end
      end

      alias [] wrap

      # @return a random CIDR
      def rand
        # both /32 and /0 are valid
        wrap(IP.rand, Kernel.rand(33))
      end

    private
      # helper for formats like 11.22.33/24
      # just adds some .0's to the end
      def parse_shortened_ip(ip_str)
        dots = ip_str.count('.')
        IP.wrap(ip_str + '.0'*(3 - dots))
      end

      def netmask_to_bits(netmask)
        raise FormatError, "CIDR: #{netmask} is not a netmask" unless netmask.netmask?

        maxint32 = 0xFFFFFFFF
        t = 1 + (maxint32 - netmask.to_i)

        # netmask.to_i.to_s(2) =~ /^(1*)0*$/
        # $1.length

        # poor man's log_2
        res = -1
        while t > 0
          res += 1
          t >>= 1
        end

        32 - res
      end

      def format_error(*args)
        args = args.map { |a| a.inspect }.join(', ')
        raise FormatError, "CIDR: unable to parse #{args}"
      end
    end

    # @return [IP] the address of the network
    attr_reader :ip

    # @return [Fixnum] the /n value
    attr_reader :bits
    alias prefix_length bits

    def initialize(ip, bits)
      @bits = bits.to_i
      @ip = IP.wrap(ip)
    end

    # CIDR of all possible IP addresses.
    # Equivalent to `CIDR('0.0.0.0/0')`
    ALL = self.new(0,0)

    # Getter for CIDR::ALL
    # @see ALL
    def self.all
      ALL
    end

    # The number of bits allocated to the network
    def inv_bits
      32 - bits
    end

    # @return [String] `#<CIDR [ 10.0.1.0/24 ]>`
    def inspect
      "#<CIDR [ #{self} ]>"
    end

    # the CIDR's netmask
    # @return [IP] the netmask
    def netmask
      @netmask ||= IP.wrap(
        ((1 << bits) - 1) << (32 - bits)
      )
    end

    # The number of addresses in the CIDR
    def size
      @size ||= (1 << inv_bits)
    end

    # Test whether an address is on the network
    # @param [IP] ip_ish the IP-ish to test.
    def include?(ip)
      IP.wrap(ip).min(bits) == min
    end

    # the lowest address on the network
    # @return [IP] the minimum address
    def min
      @min ||= IP.wrap(
        (ip.to_i >> inv_bits) << inv_bits
      )
    end
    alias :begin :min
    alias first   min
    alias prefix  min

    # the maximum address on the network
    # @return [IP] the maximum address
    def max
      @max ||= min + (size - 1)
    end
    alias :end :max
    alias last  max

    # the "rest" field is the part of the address after the
    # netmask is applied.
    # See RFC 791.
    def rest_field
      @rest_field ||= ip - min
    end
    alias rest rest_field

    # The usual CIDR representation
    def to_s
      "#{ip}/#{bits}"
    end
    alias to_str to_s

    # The number of significant octets in an address on this network.
    # 
    # @example
    #   CIDR('0.0.0.0/0').significant_octets # => 4
    #   CIDR('10.0.0.0/8').significant_octets # => 3
    #   CIDR('10.10.0.0/16').significant_octets # => 2
    #   CIDR('10.10.0.0/20').significant_octets # => 2
    #   CIDR('10.10.0.0/24').significant_octets # => 1
    #   CIDR('10.10.0.1/32').significant_octets # => 0
    def significant_octets
      4 - (bits / 8)
    end

    # The smallest classful DNS zone that will capture the range.
    # NB: may not be applicable to your DNS configs, see RFC 2317
    # @example
    #   CIDR('10.0.1/24').zone # => "1.0.10"
    # @return [String] the zone
    def zone
      ip.octets[0..-(1+significant_octets)].reverse.join('.')
    end

    # Iterates over every address in the CIDR.
    # NB: this might be huge - 2**bits
    # @yield [IP] an address in the CIDR
    # @return [CIDR] self
    def each(&blk)
      (min..max).each(&blk)
      self
    end
  end
end
