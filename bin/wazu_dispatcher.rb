#!/usr/bin/env ruby


# ########################################################################## #
# Wazu Dispatcher
# ########################################################################## #
require 'drb'
require 'beanstalk-client'

class WazuDispatcher
  include DRbUndumped

  def initialize
    @beanstalk = Beanstalk::Pool.new(['localhost:11300'])
  end

  def dispatch_job(job_info)
    @beanstalk.yput(job_info)
    puts "#{Time.now} Job #{job_info.inspect} enqueued"
  end
end


# ########################################################################## #
# Main script
# ########################################################################## #
# #### #
# Instantiate the service object
# #### #
ws = WazuDispatcher.new

# #### #
# Start up the DRb service
# #### #
DRb.start_service "druby://localhost:7000", ws

# #### #
# We need the uri of the service to connect a client
# #### #
puts DRb.uri

# #### #
# wait for the DRb service to finish before exiting
# #### #
DRb.thread.join
