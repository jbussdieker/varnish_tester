require 'yaml'

module VarnishTester
  def self.config
    YAML.load(File.read('config/settings.yml'))
  end
end
