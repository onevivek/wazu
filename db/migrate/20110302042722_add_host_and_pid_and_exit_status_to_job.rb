class AddHostAndPidAndExitStatusToJob < ActiveRecord::Migration
  def self.up
    add_column  :jobs, :host, :string
    add_column  :jobs, :pid, :string
    add_column  :jobs, :exit_status, :string
  end

  def self.down
    remove_column  :jobs, :host
    remove_column  :jobs, :pid
    remove_column  :jobs, :exit_status
  end
end
