#!/usr/bin/env ruby


# ########################################################################## #
# Command-line parameters
# Syntax : <script> <start|stop|run> -- --option1 --option2 ...
# ########################################################################## #
require 'rubygems'
require 'beanstalk-client'
require 'optiflag'
require 'yaml'
require 'pp'
require "sys/cpu"


# ########################################################################## #
# Command-line parameters
# ########################################################################## #
module WazuManagerFlags extend OptiFlagSet
  usage_flag "h","help","?"
  extended_help_flag "morehelp"

  optional_flag "environment" do
    alternate_forms "e"
    long_form "rails_environment"
    description "Rails environment"
    value_matches ["Invalid environment",/^(development|staging|production)$/]
  end

  and_process!
end

# #### #
# Set the environment
# #### #
unless WazuManagerFlags.flags.environment.nil? then
  ENV['RAILS_ENV'] = WazuManagerFlags.flags.environment
  #puts "'#{ENV['RAILS_ENV']}'"
end
require File.dirname(__FILE__) + "/../config/environment.rb"


# ########################################################################## #
# Main script
# ########################################################################## #
puts "#{Time.now} Starting wazu master"
puts "== Rails Environment = '#{ENV['RAILS_ENV']}'"
pp APP_SETTINGS
cs = "#{APP_SETTINGS['wazu_queue_host']}:#{APP_SETTINGS['wazu_queue_port']}"
puts "Connecting to queue at #{cs}"
wm = File.dirname(__FILE__) + "/wazu_master.rb"
beanstalk = Beanstalk::Pool.new([cs])
puts "Instantiated queue listener.  Going to listen mode ..."
loop do
  while 1
    one_min_avg, five_min_avg, fifteen_min_avg = Sys::CPU.load_avg()
    if one_min_avg     < APP_SETTINGS['wazu_system_one_minute_load_threshold'].to_f     and
       five_min_avg    < APP_SETTINGS['wazu_system_five_minute_load_threshold'].to_f    and
       fifteen_min_avg < APP_SETTINGS['wazu_system_fifteen_minute_load_threshold'].to_f then
      puts "Load average good, ready to receive work"
      break
    end
    puts "Sleeping for 5 seconds -- System load #{one_min_avg}, #{five_min_avg}, #{fifteen_min_avg}"
    sleep 5
  end
  queue_item = beanstalk.reserve
  puts "====================================================================="
  puts "== #{Time.now} Pulled a job from queue"
  job_info = YAML::load(queue_item.body)
  pp job_info
  job_id = job_info["job_id"]
  job_params = job_info["job_params"]
  puts "== #{Time.now} Job id '#{job_id}', params : '#{job_params.inspect}'"
  queue_item.delete
  pid = Process.fork
  if pid.nil? then
    cmd = "#{wm} -j #{job_id}"
    cmd +=  " #{job_params}" unless job_params.nil?
    puts "== #{Time.now} cmd = '#{cmd}'"
    Process.exec(cmd)
  else
    Process.detach(pid)
  end
  puts "== #{Time.now} Forked pid #{pid} for job #{job_id}"
  puts "====================================================================="
end
