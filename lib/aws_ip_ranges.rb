# frozen_string_literal: true

require "faraday"
require "faraday/net_http"
require "faraday/retry"

require "aws_ip_ranges/version"

Faraday.default_adapter = :net_http

#
# Retrieves the IP ranges from AWS.
#
module AwsIpRanges
  DEFAULT_HOST_URL = "https://ip-ranges.amazonaws.com/"

  class << self
    #
    # Fetches the latest list of IP ranges from AWS.
    #
    # @param [true,false] only_ipv6 whether to return only IP v6 ranges. Defaults to `false`.
    # @param [true,false] only_ipv4 whether to return only IP v4 ranges. Defaults to `false`.
    # @param [Array<String>,String] region a list of region to filter the ip ranges.
    # @param [Array<String>,String] service a list of services to filter the ip ranges.
    #
    # @return [Array<IPAddr>] a list of IP ranges from AWS services.
    #
    def fetch(only_ipv6: false, only_ipv4: false, region: nil, service: nil, base_url: DEFAULT_HOST_URL)
      ip_ranges = fetch_ip_ranges(base_url, only_ipv6: only_ipv6, only_ipv4: only_ipv4)
      ip_ranges = filter_by_region(ip_ranges, region)
      ip_ranges = filter_by_service(ip_ranges, service)
      ip_ranges.map do |ip_range|
        IPAddr.new(ip_range["ip_prefix"])
      end
    end

    private

    def fetch_ip_ranges(base_url, only_ipv6:, only_ipv4:)
      resp = http_client(base_url).get("/ip-ranges.json")
      aws_ip_ranges_config = JSON.parse(resp.body)

      ip_ranges = []
      ip_ranges.concat(aws_ip_ranges_config["prefixes"]) if only_ipv4 || !only_ipv6
      ip_ranges.concat(map_ipv6(aws_ip_ranges_config["ipv6_prefixes"])) if only_ipv6 || !only_ipv4
      ip_ranges
    end

    def filter_by_region(ips, regions)
      filter_by_key(ips, "region", regions)
    end

    def filter_by_service(ips, services)
      filter_by_key(ips, "service", services)
    end

    def filter_by_key(ips, key, values)
      return ips if values.nil?

      values = Array(values)
      values = values.map(&:downcase)
      ips.filter { |config| values.include?(config[key].downcase) }
    end

    def map_ipv6(prefixes)
      prefixes.each { |prefix| prefix["ip_prefix"] = prefix.delete("ipv6_prefix") }
    end

    def http_client(base_url)
      Faraday.new(url: base_url) do |faraday|
        faraday.options.timeout = 10
        faraday.request  :retry,
                         max: 5,
                         interval: 1,
                         interval_randomness: 0.5,
                         backoff_factor: 2
        faraday.response :raise_error
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
