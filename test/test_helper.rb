ENV['RACK_ENV'] = 'test'
ENV['APP_ENV'] = 'test'
ENV['CLIENT_SECRET'] = 'secret'

require 'minitest/autorun'
require 'minitest-assert-json-equal'
require 'minitest/pride'

module Minitest::Expectations
  infect_an_assertion :assert, :must_be_truthy, :unary
  infect_an_assertion :refute, :must_be_falsey, :unary

  infect_an_assertion :assert_json_equal, :must_equal_json
end
