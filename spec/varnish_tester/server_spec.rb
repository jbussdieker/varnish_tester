require 'varnish_tester/server'

describe VarnishTester::Server do
  before do
    @server = VarnishTester::Server.new
  end

  it { @server.should respond_to(:call) }
end
