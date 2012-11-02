module CommandUtils

  def run_command(command, job = nil, detach = false)
    puts "-------------------------------------------------------------------"
    puts "-- #{Time.now} run_command starting"
    @pid = nil
    puts "-- #{Time.now} run command = '#{command}'"
    @pid = Process.fork()
        
    if @pid.nil? then
      # This is the child
      begin
        ENV.delete('BUNDLE_BIN_PATH')
        ENV.delete('BUNDLE_GEMFILE')
        ENV.delete('RAILS_ENV')
        ENV.delete('RUBYOPT')
        Process.exec command
      rescue => e
        puts "-- #{Time.now} In child, run_command exception '#{e.to_s}'"
        return "child", e.to_s
      end
    else
      # This is the parent
      if detach then
        Process.detach(@pid)
    else
        
        unless job.nil? then
          job.pid = @pid
          job.save
        end
        
        pid, @process_status = Process.wait2(@pid)
        #puts @process_status
      end
    end
    puts "-- #{Time.now} run_command finished"
    puts "-------------------------------------------------------------------"

    return "parent", @process_status
  end

end
