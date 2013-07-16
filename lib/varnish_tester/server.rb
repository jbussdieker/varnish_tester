require 'rack'

module VarnishTester
  class Server
    attr_accessor :env

    def initialize(options = {})
      @options = options
    end

    def config
      VarnishTester.config
    end

    def stop
      @server_thread.kill
    end

    def run
      @server_thread = Thread.new do 
        Rack::Handler::Thin.run self, :Port => config[:upstream_port]
      end
      sleep 1
    end

    def call(env)
      @env = env
      [@options[:code], @options[:headers].to_a, "OK"]
    end

    def request
      req = Net::HTTP.const_get(@env["REQUEST_METHOD"].capitalize).new(@env["REQUEST_URI"])
      @env.each do |k,v|
        if k.start_with? "HTTP_" and k != "HTTP_VERSION"
          req[k[5..-1].gsub("_", "-")] = v
        end
      end
      req
    end

    def response
      resp = Net::HTTPResponse.new(@options[:http_version], @options[:code], "OK")
      @options[:headers].each do |k,v|
        resp.add_field k, v
      end
      resp
    end
  end
end
