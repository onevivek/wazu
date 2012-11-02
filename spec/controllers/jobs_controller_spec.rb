require 'spec_helper'

describe JobsController do

  render_views

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "should have the right title" do
      get 'index'
      response.should have_selector("title",
                                   :content => "Jobs")
    end

    it "should paginate"

    it "should have an entry for each job"
  end

=begin
  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector( "title", :content => "Jobs" )
    end
  end
=end

  describe "POST 'create'" do

    describe "failure" do
      before( :each )  do
        @attr = {
          :command => ""
        }
      end

      it "should not create invalid jobs" do
        lambda do
          post :create, :job => @attr
        end.should_not change(Job, :count)
      end

      it "should have the right title" do
        post :create, :job => @attr
        response.should have_selector("title", :content => "Jobs")
      end

      it "should render the jobs page" do
        post :create, :job => @attr
        response.should render_template('index')
      end

      it "should display an error message" do
        post :create, :job => @attr
        response.should have_selector("div>h2", :content => "prohibited")
      end
      
      it "should display a flash error message"
    end


    describe "success" do
      before( :each )  do
        @attr = {
          :command => "sleep 10; echo hello world"
        }
      end

      it "should create the job" do
        lambda do
          post :create, :job => @attr
        end.should change(Job, :count).by(1)
      end

      it "should have a success message" do
        post :create, :job => @attr
        flash[:success].should =~ /job successfully added/i
      end

      it "should redirect to the jobs page" do
        post :create, :job => @attr
        response.should redirect_to(jobs_path)
      end

    end

  end


end
