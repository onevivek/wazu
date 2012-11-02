class JobsController < ApplicationController
  def index
    @title = "Jobs"
    @jobs=Job.paginate :page => params[:page], :order => 'created_at DESC'
    @job=Job.new
  end

=begin
  def new
    @title = "Jobs"
  end
=end

  def create
    @jobs=Job.paginate :page => params[:page], :order => 'created_at DESC'
    @title = "Jobs"
    @job = Job.new(params[:job])

    if @job.save
      flash[:success] = "Job successfully added"
      redirect_to jobs_path
    else
      #redirect_to jobs_path
      flash.now[:error] = []
      @job.errors.full_messages.each do |m|
        flash.now[:error] << m
      end
      render 'index'
    end
  end

  def update

    @jobs=Job.paginate :page => params[:page], :order => 'created_at DESC'
    @title = "Jobs"
    @job = Job.new

    @djob = Job.find(params[:id])
    job_info = {"job_id" => @djob.id, "job_params" => params[:rerun] }
    if( !@djob.finished_at.nil? && params[:rerun].nil? )
      flash.now[:error] = "Job #{@djob.id} already ran.  Must force rerun to dispatch job again"
      render 'index'
    else
      @ws = DRbObject.new nil, "druby://localhost:7000"
      @ws.dispatch_job(job_info)
      flash[:success] = "Job #{@djob.id} dispatched"
      redirect_to jobs_path
    end

  end

  def destroy
    j = Job.find(params[:id]).destroy
    flash[:success] = "Job #{j.id} deleted"
    redirect_to jobs_path
  end

end
