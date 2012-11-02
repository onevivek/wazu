module JobUtils

  def run_job_list(job_ids)
    puts "==================================================================="
    begin
      raise "empty job ids list" if job_ids.empty?
      pids = []
      process_count = 0
      all_done = false
      while !all_done do
        job_ids.each do |job_id|
          puts "== #{Time.now} job id = '#{job_id}'"
          pids << run_job(job_id)
        end
        pid, status = Process.wait2(-1)
        puts "== PID = '#{pid}' done with status '#{status.exitstatus}'"
        process_count += 1
        puts "== Process count = '#{process_count}'"
        if process_count >= job_ids.size then
          all_done = true
        end
        puts "== All done = '#{all_done}'"
      end
    rescue => e
      puts "== #{Time.now} run_job_list exception #{e.to_s}"
    end
    puts "==================================================================="
  end

end
