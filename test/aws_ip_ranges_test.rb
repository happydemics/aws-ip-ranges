# frozen_string_literal: true

require "test_helper"

require "rack"
require "webrick"
require "ipaddr"

class AwsIpRangesTest < Minitest::Test
  def setup
    logger = WEBrick::Log.new(nil, WEBrick::BasicLog::WARN)
    @server = WEBrick::HTTPServer.new(Host: @host = "localhost", Port: @port = 22_222, Logger: logger, AccessLog: [])
    @server.mount "/", Rack::Handler::WEBrick, Rack::File.new("test/fixtures")

    @thread = Thread.new { @server.start }
    trap(:INT) { @server.shutdown }
    wait_for_server_ready
  end

  def teardown
    @server.shutdown
    @thread.join
  end

  def test_it_fetches_all_ips
    assert_match_fixture(fetch, :all)
  end

  def test_it_fetches_only_ipv4
    assert_match_fixture(fetch(only_ipv4: true), :ipv4)
  end

  def test_it_fetches_only_ipv4_eu_west_1 # rubocop:disable Naming/VariableNumber
    assert_match_fixture(fetch(only_ipv4: true, region: ["eu-west-1"]), :ipv4_eu_west_1) # rubocop:disable Naming/VariableNumber
  end

  def test_it_fetches_only_ipv6
    assert_match_fixture(fetch(only_ipv6: true), :ipv6)
  end

  def test_it_fetches_only_ipv6_cloudfront
    assert_match_fixture(fetch(only_ipv6: true, service: ["cloudfront"]), :ipv6_cloudfront)
  end

  def test_it_fetches_only_ipv6_cloudfront_s3
    assert_match_fixture(fetch(only_ipv6: true, service: %w[cloudfront s3]), :ipv6_cloudfront_s3)
  end

  def test_it_failed_to_fetch
    @server.shutdown

    expected_msg = "Failed to load IP ranges: Failed to open TCP connection to localhost:22222 "\
                   "(Connection refused - connect(2) for 127.0.0.1:22222)"
    assert_raises(Faraday::ConnectionFailed, expected_msg) { fetch }
  end

  def test_the_cli_fetches_all_ips
    assert_cli_match_fixture(cli, :all)
  end

  def test_the_cli_fetches_only_ipv4
    assert_cli_match_fixture(cli(only_ipv4: true), :ipv4)
  end

  def test_the_cli_fetches_only_ipv4_eu_west_1 # rubocop:disable Naming/VariableNumber
    assert_cli_match_fixture(cli(only_ipv4: true, region: ["eu-west-1"]), :ipv4_eu_west_1) # rubocop:disable Naming/VariableNumber
  end

  def test_the_cli_fetches_only_ipv6
    assert_cli_match_fixture(cli(only_ipv6: true), :ipv6)
  end

  def test_the_cli_fetches_only_ipv6_cloudfront
    assert_cli_match_fixture(cli(only_ipv6: true, service: ["cloudfront"]), :ipv6_cloudfront)
  end

  def test_the_cli_fetches_only_ipv6_cloudfront_s3
    assert_cli_match_fixture(cli(only_ipv6: true, service: %w[cloudfront s3]), :ipv6_cloudfront_s3)
  end

  def test_the_cli_failed_to_fetch
    @server.shutdown
    ips, err = cli

    assert_equal([], ips)
    assert_match(/Failed to load IP ranges: Failed to open TCP connection to localhost:22222/, err)
  end

  private

  def assert_cli_match_fixture(ips_with_err, fixture_name)
    ips, = ips_with_err
    content = File.readlines(File.join("test/fixtures", "#{fixture_name}.csv"), chomp: true)
    assert_equal(content.sort, ips.sort)
  end

  def assert_match_fixture(ips, fixture_name)
    content =    File.readlines(File.join("test/fixtures", "#{fixture_name}.csv"), chomp: true)
    expected_ips = content.map { |ip| IPAddr.new(ip) }
    assert_equal(sort_ips(expected_ips), sort_ips(ips))
  end

  def sort_ips(ips)
    ips.map { |ip| sortable_ip(ip) }
  end

  def sortable_ip(ip)
    [ip.to_s, ip.prefix]
  end

  def fetch(**kwargs)
    AwsIpRanges.fetch(base_url: "http://localhost:22222/", **kwargs)
  end

  def cli(only_ipv4: nil, only_ipv6: nil, region: nil, service: nil)
    out, err = capture_subprocess_io do
      opts = ""
      opts = "#{opts} --only-ipv4" if only_ipv4
      opts = "#{opts} --only-ipv6" if only_ipv6
      opts = "#{opts} --region #{region.join(",")}" if region
      opts = "#{opts} --service #{service.join(",")}" if service

      system "AWS_IP_RANGE_HOST_URL='http://localhost:22222' ruby -Ilib exe/aws-ip-ranges list #{opts}"
    end
    [out.split("\n"), err]
  end

  def wait_for_server_ready
    seconds = 10
    wait_time = 0.01
    until @server.status == :Running || seconds <= 0
      seconds -= wait_time
      sleep wait_time
    end

    return if @server.status == :Running

    raise "Server was not started"
  end
end
