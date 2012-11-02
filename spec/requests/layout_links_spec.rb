require 'spec_helper'

describe "LayoutLinks" do

  it "should have a home page at /" do
    get '/'
    response.should have_selector("title",
                                  :content => "Home")
  end

  it "should have a jobs page at /jobs" do
    get '/jobs'
    response.should have_selector("title",
                                 :content => "Jobs")
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "jobs"
    response.should have_selector( "title", :content => "Jobs" )
    click_link "home"
    response.should have_selector( "title", :content => "Home" )
  end

end
