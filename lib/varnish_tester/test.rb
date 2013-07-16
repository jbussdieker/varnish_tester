module VarnishTester
  class Test
    def initialize(path)
      @path = path
    end

    def ds_response
      @ds_response ||= client.response
    end

    def us_response
      ds_response
      @us_response ||= server.response
    end

    def ds_request
      ds_response
      @ds_request ||= client.request
    end

    def us_request
      ds_response
      @us_request ||= server.request
    end

    def client
      @client ||= VarnishTester::Client.new(request)
    end

    def server
      @server ||= VarnishTester::Server.new(response)
    end

    def check(type, actual, expected)
      extra_headers = []
      missing_headers = []

      actual.each do |k,v|
        expected[:headers].each do |ek,ev|
          if k.downcase == ek.downcase and v.downcase != ev.downcase
            puts "  #{type} Error #{k} is #{v} but should be #{ev}"
          end
        end
      end

      if expected[:strict]
        actual.each do |k,v|
          found = false
          expected[:headers].each do |ek,ev|
            if k.downcase == ek.downcase
              found = true
            end
          end
          extra_headers << k unless found or expected[:ignore_headers].include? k.downcase
        end
        expected[:headers].each do |ek,ev|
          found = false
          actual.each do |k,v|
            if k.downcase == ek.downcase
              found = true
            end
          end
          missing_headers << ek unless found or expected[:ignore_headers].include? ek.downcase
        end
        if missing_headers.length > 0
          puts "  The following #{type} headers are expected but not being added"
          missing_headers.each do |h|
            puts "    - #{h}"
          end
        end
        if extra_headers.length > 0
          puts "  The following #{type} headers are not expected but being added"
          extra_headers.each do |h|
            puts "    - #{h}"
          end
        end
      end
    end

    def run
      puts "Testing #{@path.split("/").last}"
      server.run
      check "Request", us_request, expected_request
      check "Response", ds_response, expected_response
      server.stop
    end

    def request
      YAML.load(File.read(File.join(@path, "request.yml")))
    end

    def expected_request
      e = YAML.load(File.read(File.join(@path, "expected_request.yml")))
      (e[:ignore_headers] || []).each {|h| h.downcase!}
      e
    end

    def response
      YAML.load(File.read(File.join(@path, "response.yml")))
    end

    def expected_response
      e = YAML.load(File.read(File.join(@path, "expected_response.yml")))
      (e[:ignore_headers] || []).each {|h| h.downcase!}
      e
    end
  end
end
