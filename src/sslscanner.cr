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
      sort_and_print(gather_results)
    end

    def gather_results
      scans = [] of Hash(Symbol, (String | Colorize::Object(String)))
      results = [] of Int32
      spawns = [] of Int32
      SSLScanner.protocols.each do |symbol, protocol_bits|
        SSLScanner.ciphers.each do |cipher|
          spawn do
            spawns << 0
            if ssl_handshake(cipher, protocol_bits)
              eva = SSLScanner::Evalutation.new(cipher, symbol)
              scans << eva.evaluate
            end
            results << 0
          end
        end
      end
      sleep 1
      until results.size == spawns.size
        print "\rScanning: #{results.size}/#{spawns.size}"
        sleep 1
      end
      scans
    end

    def sort_and_print(results : Array(Hash(Symbol, Colorize::Object(String) | String)))
      puts "\r\nThe server #{@ip}:#{@port} supports those ciphers and protocols".colorize(:blue)
      SSLScanner.protocols.each do |symbol, protocol_bits|
        results.each do |result|
          if result[:protocol] == symbol.to_s
            puts "#{result[:protocol]} -- #{result[:cipher]} -- #{result[:bits]} -- #{result[:strength]} -- #{result[:issues]}"
          else
            next
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
