#!/usr/bin/env ruby

require 'drb'

wc = DRbObject.new nil, "druby://localhost:6999"
#puts wc.schedule_new_job_now("sleep 10")
puts wc.schedule_new_batch_now({:name => "name", :throttle => "1"}, "sleep 10", "sleep 30", "sleep 40", "sleep 50", "sleep 60")
