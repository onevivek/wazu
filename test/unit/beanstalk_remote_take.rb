#!/usr/bin/env ruby

require 'rubygems'
require 'beanstalk-client'
require 'pp'

beanstalk = Beanstalk::Pool.new(['50.17.240.54:11300'])
loop do
  # #### #
  # String message
  # #### #
  job = beanstalk.reserve
  pp job.body
  job.delete

  # #### #
  # YAML message
  # #### #
  job = beanstalk.reserve
  obj = YAML::load(job.body)
  pp obj
  job.delete
end
