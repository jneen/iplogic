class Fixnum
  def radix(rad)
    raise ArgumentError if self < 0
    return [] if zero?

    i = self
    digits = []
    while i > 0
      i, r = i.divmod(rad)
      digits << r
    end
    digits.reverse
  end unless 0.respond_to? :radix
end
