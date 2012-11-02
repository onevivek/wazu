class ChangeCommandFieldTypeInJobs < ActiveRecord::Migration
  def self.up
    change_table :jobs do |t|
      remove_column :jobs, :command
      add_column    :jobs, :command, :text
    end
  end

  def self.down
    change_table :jobs do |t|
      remove_column :jobs, :command
      add_column    :jobs, :command, :string
    end
  end
end
