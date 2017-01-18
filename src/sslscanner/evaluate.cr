module SSLScanner
  class Evalutation
    def initialize(cipher : String, protocol : Symbol)
      @cipher = cipher
      @protocol = protocol
      @evaluated = {:cipher => cipher}
    end

    def evaluate
      @evaluated[:strength] = cipher_strength
      @evaluated[:bits] = bit_size == 0 ? "" : bit_size.to_s
      @evaluated[:issues] = issue
      @evaluated
    end

    def cipher_strength
      case @cipher
      when /(MD5|RC4|NULL|RC2|DES|GOST|EXP)/i
        "low"
      when /(128|3DES)/i
        "medium"
      when /(SHA384|ECDHE|ECDSA)/i
        "high"
      else
        "normal"
      end
    end

    def bit_size
      bits = @cipher.gsub(/\D/, "")[0..2]
      bits = "" if bits.size < 2
      bits
    end

    def issue
      issues = [] of String
      issues << "FREAK - CVE-2015-0204" if @cipher =~ /EXP/i
      issues << "Bar Mitzvha Attack - CVE-2015-2808" if @cipher =~ /RC4/i
      issues << "POODLE - CVE-2014-3566" if @cipher =~ /CBC/i && @protocol == :ssl3
      issues << "POODLE - CVE-2014-8730" if @cipher =~ /CBC/i && @protocol == :tls1

      issues.join(", ")
    end
  end
end
