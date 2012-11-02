class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string :name
      t.string :command
      t.timestamp :starting_at
      t.timestamp :finished_at
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
