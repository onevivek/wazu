# == Schema Information
# Schema version: 20110305063355
#
# Table name: crons
#
#  id         :integer(4)      not null, primary key
#  time_spec  :string(255)     not null
#  name       :string(255)     not null
#  command    :string(255)     not null
#  recurring  :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

class Cron < ActiveRecord::Base
end
