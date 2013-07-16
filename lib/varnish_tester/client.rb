require 'net/http'

module VarnishTester
  class Client
    def initialize(options = {})
      @options = options
    end

    def config
      VarnishTester.config
    end

    def client
      @client ||= Net::HTTP.new('localhost', config[:downstream_port])
    end

    def response
      client.request(request)
    end

    def request
      req = Net::HTTP.const_get(@options[:method].capitalize).new(@options[:path] || "/")
      @options[:headers].each do |key,value|
        req[key] = value
      end
      req
    end
  end
end
