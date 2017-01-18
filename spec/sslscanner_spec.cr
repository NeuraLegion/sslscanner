require "./spec_helper"

describe SSLScanner do
  it "ciphers are array" do
    SSLScanner.ciphers.is_a? Array
  end
  it "list all ciphers" do
    puts SSLScanner.ciphers
  end
  it "scans google.com" do
    scanner = SSLScanner::Scan.new("google.com", 443)
    scanner.run
  end
  it "scans facebook.com" do
    scanner = SSLScanner::Scan.new("facebook.com", 443)
    scanner.run
  end
end
