require 'pp'
require 'rubygems'
require 'net/ssh'
require 'net/scp'

namespace :jobs do
  namespace :failed do
    desc "Cleanup failed Jobs"
    task :cleanup, :needs => :environment do |t, args|
      hosts = {}
      puts "-----------------------------------------------------------------"
      puts "-- #{Time.now} rake jobs:failed:cleanup starting"
      puts "-- #{Time.now} Environment '#{Rails.env}'"
      finished_jobs = Job.where(:exit_status => 1)
      finished_jobs.each do |job|
        #pp job
        #puts job.host
        raise "Missing host for job id #{job.id}" unless job.host
        hosts[job.host] ||= []
        hosts[job.host] << job.id
        archive_job = ArchiveJob.new
        archive_job.id = job.id
        archive_job.name = job.name
        archive_job.command = job.command
        archive_job.starting_at = job.starting_at
        archive_job.finished_at = job.finished_at
        archive_job.created_at = job.created_at
        archive_job.updated_at = job.updated_at
        archive_job.host = job.host
        archive_job.pid = job.pid
        archive_job.exit_status = job.exit_status
        archive_job.comment = job.comment
        archive_job.execution_paramters = job.execution_paramters
        if archive_job.save then
          job.delete
        end
      end
      hosts.keys.each do |host|
        puts "-- Getting log files from host '#{host}'"
        job_ids = hosts[host]
        job_ids.each do |job_id|
          remote_file = "/var/tmp/job_#{job_id}.log"
          local_file = "/store/logs/job_logs/job_#{job_id}.log"
          puts "-- job_id = '#{job_id}', remote file = '#{remote_file}'," \
             + " local file = '#{local_file}'"
          cmd = "/usr/bin/rsync" \
              + " -e '/usr/bin/ssh -i /home/rails/.ssh/wazu_master_key'" \
              + " --remove-sent-files rails@10.86.214.67:#{remote_file}" \
              + " #{local_file}"
          puts "-- cmd = '#{cmd}'"
          `#{cmd}`
        end
      end
      puts "-- #{Time.now} rake jobs:failed:cleanup finished"
      puts "-----------------------------------------------------------------"
    end
  end
end
