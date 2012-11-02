# == Schema Information
# Schema version: 20110305063355
#
# Table name: jobs
#
#  id                  :integer(4)      not null, primary key
#  name                :string(255)
#  command             :string(255)
#  starting_at         :datetime
#  finished_at         :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  host                :string(255)
#  pid                 :string(255)
#  exit_status         :string(255)
#  comment             :string(255)
#  execution_paramters :string(255)
#

class Job < ActiveRecord::Base
  attr_accessible :name, :command, #:starting_at, :finished_at, 
                  #:created_at, :updated_at,
                  #:host, :pid, :exit_status,
                  #:comment,
                  :execution_paramters
  belongs_to :batch
  validates :command, :presence => true
end
