require "../src/sslscanner"

puts "Usage: ./scan [host] [port]"
raise "not enough arguments given" if ARGV.size < 2
host = ARGV[0]
port = ARGV[1].to_i
scanner = SSLScanner::Scan.new(host, port)
scanner.run
