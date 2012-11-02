#!/usr/bin/env ruby

require 'rubygems'
require 'beanstalk-client'

beanstalk = Beanstalk::Pool.new(['localhost:11300'])
ARGV.each do |x|
  beanstalk.put(x)
end
