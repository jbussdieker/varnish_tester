module VarnishTester
  class Varnish
    def initialize(config_file='config/sample.vcl')
      @config_file = config_file
    end

    def config
      VarnishTester.config
    end

    def pid_file
      File.join(config[:varnish_tmp], "varnish.pid")
    end

    def start
      @varnish_thread = Thread.new do
        cmd = "varnishd -F -P #{pid_file} -n #{config[:varnish_tmp]} -a :#{config[:downstream_port]} -f #{@config_file} -s malloc,256m 2>&1"
        `#{cmd}`
      end
    end

    def stop
      Process.kill(9, File.read(pid_file).to_i)
    end

    def restart
      stop; start
    end
  end
end
