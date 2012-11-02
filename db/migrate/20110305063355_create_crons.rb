class CreateCrons < ActiveRecord::Migration
  def self.up
    create_table :crons do |t|
      t.string :time_spec, :null => false
      t.string :name, :null => false
      t.string :command, :null => false
      t.boolean :recurring, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :crons
  end
end
