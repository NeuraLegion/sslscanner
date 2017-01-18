module SSLScanner
  class Evalutation
    def initialize(cipher : String, protocol : Symbol)
      @cipher = cipher
      @protocol = protocol
      @evaluated = Hash(Symbol, (String | Colorize::Object(String))).new
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
        "low".colorize(:red)
      when /(128|3DES)/i
        "medium".colorize(:yellow)
      when /(SHA384|ECDHE|ECDSA)/i
        "high".colorize(:green)
      else
        "normal"
      end
    end

    def bit_size
      bits = @cipher.gsub(/\D/, "")[0..2]
      bits = "" if bits.size < 2
      if bits.to_i < 128
        bits.colorize(:red)
      elsif bits.to_i < 256
        bits.colorize(:yellow)
      elsif bits.to_i > 300
        bits.colorize(:green)
      else
        bits
      end
    rescue
      ""
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
