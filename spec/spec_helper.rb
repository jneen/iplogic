require 'rubygems'
require 'bundler'
Bundler.require

require 'minitest/spec'

Wrong.config[:color] = true

class MiniTest::Unit::TestCase
  include Wrong
end

require 'iplogic'
include IPLogic
