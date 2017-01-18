require "colorize"
require "socket"
require "openssl"
require "./sslscanner/*"

module SSLScanner
  class Scan
    def initialize(ip : String, port : Int32)
      @ip = ip
      @port = port
    end

    def run
      puts "The server supports those ciphers and protocols"
      SSLScanner.protocols.each do |symbol, protocol_bits|
        SSLScanner.ciphers.each do |cipher|
          if ssl_handshake(cipher, protocol_bits)
            eva = SSLScanner::Evalutation.new(cipher, symbol)
            cipher_info = eva.evaluate
            puts "#{symbol} -- #{cipher} -- #{cipher_info[:bits]} -- #{cipher_info[:strength]} -- #{cipher_info[:issues]}"
          end
        end
      end
    end

    def socket
      begin
        TCPSocket.new(@ip, @port)
      rescue e : Exception
        raise "Error connecting to target #{@ip}:#{@port} : #{e}"
      end
    end

    def ssl_handshake(cipher : String, protocol : Array(OpenSSL::SSL::Options))
      begin
        s = socket
        c = OpenSSL::SSL::Context::Client.new
        c.ciphers = cipher
        c.verify_mode = OpenSSL::SSL::VerifyMode::NONE
        protocol.each do |option|
          c.add_options(option)
        end
        OpenSSL::SSL::Socket::Client.new(s, c)
        s.close if s.is_a? TCPSocket rescue nil
        true
      rescue
        s.close if s.is_a? TCPSocket rescue nil
        false
      end
    end
  end
end
