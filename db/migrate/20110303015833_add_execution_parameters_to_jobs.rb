class AddExecutionParametersToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :execution_paramters, :string
  end

  def self.down
    remove_column :jobs, :execution_paramters
  end
end
