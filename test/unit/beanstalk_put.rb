#!/usr/bin/env ruby

require 'rubygems'
require 'beanstalk-client'

beanstalk = Beanstalk::Pool.new(['localhost:11300'])
i = 0
while true do
  i = i + 1
  beanstalk.put("#{$$} hello #{i}")
  beanstalk.yput({:message => "#{$$} hello #{i}"})
  sleep 1
end
