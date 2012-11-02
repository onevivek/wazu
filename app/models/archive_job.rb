class ArchiveJob < ActiveRecord::Base
  attr_accessible :name, :command, #:starting_at, :finished_at, 
                  #:created_at, :updated_at,
                  #:host, :pid, :exit_status,
                  #:comment,
                  :execution_paramters
  belongs_to :batch
  validates :command, :presence => true
end
