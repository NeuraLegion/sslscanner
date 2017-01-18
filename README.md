# sslscanner

TODO: Write a description here

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  sslscanner:
    github: bararchy/sslscanner
```

## Usage

```crystal
require "sslscanner"
# This will start a scan of google.com
scanner = SSLScanner::Scan.new("google.com", 443)
scanner.run
```

## Development

- [ ] Add more issues (SSL Issues)  
- [ ] Multiscanning (using fibers)  
- [ ] Export results to pdf\txt\csv\etc..  
- [ ] Add local OpenSSL installation with all ciphers enabled so we dont need to relay on system openssl  

## Contributing

1. Fork it ( https://github.com/bararchy/sslscanner/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [bararchy]](https://github.com/bararchy) - creator, maintainer
