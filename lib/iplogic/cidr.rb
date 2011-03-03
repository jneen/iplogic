module IPLogic
  class CIDR
    include Enumerable

    class << self
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

          new(ip, bits)
        elsif args.size == 1
          arg = args.first
          if arg =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\/(\d+)/
            new($1, $2)
          else
            format_error(arg)
          end
        end
      end
    private
      def netmask_to_bits(netmask)
        raise FormatError, "CIDR: #{netmask} is not a netmask" unless netmask.netmask?
        # TODO: there's probably a clever mathy way to do this,
        # but this works just fine.
        netmask.to_i.to_s(2) =~ /^(1*)0*$/
        $1.length
      end

      FormatError = Class.new(ArgumentError)
      def format_error(*args)
        args = args.map { |a| a.inspect }.join(', ')
        raise FormatError, "CIDR: unable to parse #{args}"
      end
    end

    attr_reader :ip, :bits
    alias prefix_length bits

    def initialize(ip, bits)
      @bits = bits.to_i
      @ip = IP.wrap(ip)
    end

    ALL = self.new(0,0)
    def self.all
      ALL
    end

    def inv_bits
      32 - bits
    end

    def inspect
      "#<CIDR [ #{self} ]>"
    end

    def netmask
      @netmask ||= IP.wrap(
        ((1 << bits) - 1) << (32 - bits)
      )
    end

    def size
      @size ||= (1 << inv_bits)
    end

    def include?(ip)
      IP.wrap(ip).min(bits) == min
    end

    def min
      @min ||= IP.wrap(
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

    def to_s
      "#{ip}/#{bits}"
    end
    alias to_str to_s

    def significant_octets
      4 - (bits / 8)
    end

    def zone
      ip.parts[0..-(1+significant_octets)].reverse.join('.')
    end

    def each(&blk)
      (min..max).each(&blk)
    end
  end

  def CIDR(*args)
    return CIDR if args.empty?

    CIDR.wrap(*args)
  end
end
