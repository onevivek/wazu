#!/usr/bin/env ruby


# ########################################################################## #
# Includes
# ########################################################################## #
require 'rubygems'
require 'optiflag'
require 'rufus/scheduler'
require 'drb'
require 'pp'
require 'sys/cpu'


# ########################################################################## #
# Command-line parameters
# ########################################################################## #
module WazuCronFlags extend OptiFlagSet
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
unless WazuCronFlags.flags.environment.nil? then
  ENV['RAILS_ENV'] = WazuCronFlags.flags.environment
  puts "'#{ENV['RAILS_ENV']}'"
end
require File.dirname(__FILE__) + "/../config/environment.rb"


# ########################################################################## #
# Wazu Cron
# ########################################################################## #
class WazuCron
  include DRbUndumped

  def initialize
    @scheduler = Rufus::Scheduler.start_new
    @ws = DRbObject.new nil, "druby://localhost:7000"
  end

  def schedule_cron_job(time_spec, job_info)
    puts "#{Time.now} cron_job"
    pp job_info
    @scheduler.cron(time_spec) do
      puts "#{Time.now} Job cronned as per #{time_spec}"
      @ws.dispatch_job(job_info)
    end
  end

  def schedule_job_in(time_spec, job_info)
    puts "#{Time.now} cron_job"
    pp job_info
    @scheduler.in(time_spec) do
      puts "#{Time.now} Job Scheduled to be run in #{time_spec}"
      @ws.dispatch_job(job_info)
    end
  end

  def schedule_new_job_now(job_command, job_name = "")
    j = Job.new({:command => job_command})
    j.name = job_name unless job_name.nil?
    j.save
    @ws.dispatch_job({"job_id" => j.id, "job_command" => job_command})
    return j.id
  end

  def schedule_new_batch_now(batch_params = {}, *commands)
    bp = {}
    bp[:name] = batch_params[:name]
    bp[:command] = batch_params[:command]
    b = Batch.new(bp)
    b.save
    puts b.id
    throttle = batch_params[:throttle]
    if !throttle.nil? then
      puts throttle
      raise "Throttle must be numeric" unless throttle.match(/^\d+$/)
    end
    commands.each do |c|
      j = Job.new({:command => c})
      j.name = "Batch Job - Batch #{b.id}"
      j.batch_id = b.id
      j.save
      @ws.dispatch_job({"job_id" => j.id, "job_command" => c})
      sleep throttle.to_i unless throttle.nil?
    end
  end
  
  def jobs_by_condition(condition)
    jobHash_list = []
    Job.where( condition ).each do |job|
      job_hash = { :id                  => job.id,
                   :name                => job.name,
                   :command             => job.command,
                   :starting_at         => job.starting_at,
                   :finished_at         => job.finished_at,
                   :created_at          => job.created_at,
                   :updated_at          => job.updated_at,
                   :host                => job.host,
                   :pid                 => job.pid,
                   :exit_status         => job.exit_status,
                   :comment             => job.comment,
                   :execution_paramters => job.execution_paramters                   
                 }
      jobHash_list << job_hash
    end
    return jobHash_list
  end
  
  require "#{RAILS_ROOT}/lib/command_utils.rb"
  include CommandUtils
  def kill_job(job_id, program_name)
    job = Job.find(job_id)
    if job.exit_status.nil? then
      kill_command = "cd /home/rails/wazu/bin; /usr/local/bin/cap remote_command hosts=#{job.host} command='cd /home/rails/wazu/bin; ./process_kill.sh #{job.pid} #{program_name};'"
      run_command( kill_command )
      job.exit_status = -9
      job.save
    end
  end
end


# ########################################################################## #
# Main script
# ########################################################################## #
# #### #
# Instantiate the service object
# #### #
wc = WazuCron.new

# #### #
# Read all the cron jobs in the table
# #### #
Cron.all.each do |c|
  pp c
  job = Job.new({:command => c.command, :name => c.name})
  job.save
  job_info = {"job_id" => job.id, "job_params" => nil}
  if c.recurring then
    job_info["job_params"] = "-r"
    wc.schedule_cron_job(c.time_spec, job_info)
  else
    wc.schedule_job_in(c.time_spec, job_info)
    c.delete
  end
end

# #### #
# Start up the DRb service
# #### #
#DRb.start_service "druby://localhost:6999", wc
DRb.start_service "druby://0.0.0.0:6999", wc

# #### #
# We need the uri of the service to connect a client
# #### #
puts DRb.uri

# #### #
# wait for the DRb service to finish before exiting
# #### #
DRb.thread.join
