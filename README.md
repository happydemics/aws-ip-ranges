# `aws-ip-ranges`

Retrieve AWS IP ranges with ease.

## Installation

Run:

```sh
gem install aws-ip-ranges
```

## Usage

### Code

```ruby
AwsIpRanges.fetch(service: ['cloudfront', 's3']) # => [#<IPAddr: IPv4:3.2.34.0/255.255.255.192>,  #<IPAddr: IPv4:3.5.140.0/255.255.252.0>]
AwsIpRanges.fetch(region: 'eu-west-3')
AwsIpRanges.fetch(only_ipv4: true)
AwsIpRanges.fetch(only_ipv6: true)
```

### CLI

Execute:

```sh
$ aws-ip-ranges list
35.172.155.192/27
35.172.155.96/27
44.192.134.240/28
...
2600:1f70:c000:400::/56
```

See the help for more usage:

```sh
Command:
  aws-ip-ranges list

Usage:
  aws-ip-ranges list

Description:
  List all AWS IP ranges

Options:
  --[no-]only-ipv6                  # Whether to include only IPv6 ranges., default: false
  --[no-]only-ipv4                  # Whether to include only IPv4 ranges., default: false
  --service=VALUE1,VALUE2,..        # Which services to include. By default, includes all.
  --region=VALUE1,VALUE2,..         # Which regions to include. By default, includes all.
  --help, -h                        # Print this help

Examples:
  aws-ip-ranges list                                             # Prints all AWS IP ranges
  aws-ip-ranges list --only-ipv4                                 # Prints all AWS IPv4 ranges
  aws-ip-ranges list --only-ipv6 --service=cloudfront,global     # Prints AWS Cloudfront and Global IPv6 ranges
  aws-ip-ranges list --only-ipv6 --service=s3 --region=eu-west-1 # Prints AWS S3 IPv6 ranges in the eu-west-1 region
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

We are not accepting outside contribution on this library at the moment.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
