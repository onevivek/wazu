class AddBatchIdToJob < ActiveRecord::Migration
  def self.up
    add_column  :jobs, :batch_id, :integer
  end

  def self.down
    remove_column  :jobs, :batch_id
  end
end
