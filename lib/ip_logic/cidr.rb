module IPLogic
  class CIDR
    include Enumerable

    class << self
      def parse(*args)
        return args.first if args.first.is_a? CIDR
        if args.size == 2
          ip, bits = args

          bits = case bits
          when Integer
            bits
          when String
            netmask_to_bits(IP(bits))
          when IP
            netmask_to_bits(bits)
          else
            bits.to_i
          end

          new(ip, bits)
        elsif args.size == 1
          arg = args.first
          if arg =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\/(\d+)/
            new($1, $2)
          end
        end
      end
    private
      def netmask_to_bits(netmask)
        # TODO: there's probably a clever mathy way to do this,
        # but this works just fine.
        netmask.to_i.to_s(2) =~ /^(1*)0*$/
        $1.length
      end
    end

    attr_reader :ip, :bits
    alias prefix_length bits

    def initialize(ip, bits)
      @bits = bits.to_i
      @ip = IP(ip)
    end

    ALL = self.new(0,0)
    def all
      ALL
    end

    def inv_bits
      32 - bits
    end

    def inspect
      "#<IPLogic::CIDR [ #{ip}/#{bits} ]>"
    end

    def netmask
      @netmask ||= IP(
        ((1 << bits) - 1) << (32 - bits)
      )
    end

    def size
      @size ||= (1 << inv_bits)
    end

    def min
      @min ||= IP(
        (ip.to_i >> inv_bits) << inv_bits
      )
    end
    alias :begin :min
    alias first   min
    alias prefix  min

    def max
      @max ||= min + (size - 1)
    end
    alias :end :max
    alias last  max

    def rest_field
      @rest_field ||= ip - min
    end
    alias rest rest_field

    def significant_octets
      4 - (bits / 8)
    end

    def zone
      i.parts[0..-(1+significant_octets)].reverse.join('.')
    end

    def each(&blk)
      (min..max).each(&blk)
    end
  end

  def CIDR(*args)
    return CIDR if args.empty?

    CIDR.parse(*args)
  end
end
