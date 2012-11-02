class CreateArchiveJobs < ActiveRecord::Migration
  def self.up
    create_table :archive_jobs do |t|
      t.string :name
      t.string :command
      t.timestamp :starting_at
      t.timestamp :finished_at
      t.timestamps
      t.string :host
      t.string :pid
      t.string :exit_status
      t.string :comment
      t.string :execution_paramters
      t.integer :batch_id
    end
  end

  def self.down
    drop_table :archive_jobs
  end
end
