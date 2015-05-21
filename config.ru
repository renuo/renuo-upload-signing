$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'app'
require 'newrelic_rpm'
run Sinatra::Application
