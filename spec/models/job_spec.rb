require 'spec_helper'

describe Job do
#  pending "add some examples to (or delete) #{__FILE__}"

  before(:each) do
    @attr = {
      :name => "sample job",
      :command => "sleep 5",
      :execution_paramters => ""
    }
  end

  it "should create an instance given valid params" do
    Job.create!(@attr)
  end

  it "should require a command" do
    j = Job.new(@attr.merge( :command => "" ))
    j.should_not be_valid
  end

end
