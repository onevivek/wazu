#!/usr/bin//env ruby


# ########################################################################## #
# Includes
# ########################################################################## #
require 'rubygems'
require 'optiflag'
require 'pp'


# ########################################################################## #
# Command-line parameters
# ########################################################################## #
module WazuMasterFlags extend OptiFlagSet
  usage_flag "h","help","?"
  extended_help_flag "morehelp"

  optional_flag "environment" do
    alternate_forms "e"
    long_form "rails_environment"
    description "Rails environment"
    value_matches ["Invalid environment", /^(development|production)$/]
  end

  flag "job_id" do
    alternate_forms "j"
    description "Job ID"
    value_matches ["Positive Integer", /^\d+$/]
  end

  optional_switch_flag "rerun" do
    alternate_forms "r"
    description "Re-run job"
  end

  and_process!
end

# #### #
# Set the environment
# #### #
unless WazuMasterFlags.flags.environment.nil? then
  ENV['RAILS_ENV'] = WazuMasterFlags.flags.environment
  puts "'#{ENV['RAILS_ENV']}'"
end
require File.dirname(__FILE__) + "/../config/environment.rb"
require "#{RAILS_ROOT}/lib/command_utils.rb"
include CommandUtils


# ########################################################################## #
# Main script
# ########################################################################## #
# #### #
# Check job
# #### #
job_id = WazuMasterFlags.flags.job_id

begin
  job = Job.find(job_id)
rescue ActiveRecord::RecordNotFound => err
  #puts( "==>#{err.class}" )
  #puts( "==>#{err.methods.join(', ')}" )
  STDERR.puts( "#{err.message}" )
  exit 1
end
raise "Job::run error -- Missing command" if job.command.blank?

# #### #
# Re-direct stdout and stderr
# #### #
orig_stdout = $stdout
orig_stderr = $stderr
$stdout.reopen("/var/tmp/job_#{job_id}.log", "w")
$stderr.reopen("/var/tmp/job_#{job_id}.log", "w")

# #### #
# Job init
# #### #
if WazuMasterFlags.flags.rerun then
  #unless job.exit_status.nil? then
  #  raise "Job exit status must be non-zero to re-run" if job.exit_status.to_i == 0
  #end
  job.starting_at = nil
  job.finished_at = nil
  job.updated_at = nil
  job.host = nil
  job.pid = nil
  job.exit_status = nil
  job.comment = nil
  job.save
end

# #### #
# Execute Job
# #### #

raise "Job already ran" unless job.finished_at.nil?
job.starting_at = Time.now
require "socket"
job.host = Socket.gethostname
job.save
@job_status = nil
@process_origin = nil
begin
  @process_origin, @job_status = run_command(job.command, job, false)
  puts "'#{@process_origin}', '#{@job_status}'"
rescue => e
  puts "Error -- #{e.to_s}"
end

# #### #
# Update job run details
# #### #
begin
  job.finished_at = Time.now
  if @process_origin == "child" and !@job_status.nil? then
    job.comment = @job_status
  end
  if @process_origin == "parent" and !@job_status.nil? then
    job.pid = @pid
#    require "socket"
#    job.host = Socket.gethostname
    job.exit_status = @job_status.exitstatus
  end
  job.save
rescue ActiveRecord::StatementInvalid => e
  # #### #
  # This error happens when the child process exits on an error.
  # This causes the active record connection to drop.  Here, we reconnect.
  # #### #
  ActiveRecord::Base.verify_active_connections!
  job.save
end

# #### #
# Re-direct stdout and stderr to its default
# #### #
#$stdout = orig_stdout
#$stderr = orig_stderr
