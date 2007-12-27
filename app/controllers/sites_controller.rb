class SitesController < ApplicationController
  before_filter :admin_required, :only => [ :destroy, :update, :edit ]

  def index
    @sites = Site.paginate(:all, :page => params[:page], :order => 'host ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  def show
    @site = Site.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end

  def new
    @site = Site.new :host => request.host

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site }
    end
  end

  def edit
    @site = Site.find(params[:id])
  end

  def create
    @site = Site.new(params[:site])

    respond_to do |format|
      if @site.save
        flash[:notice] = 'Site was successfully created.'
        flash[:notice] += ' Please create your account.' unless logged_in?
        format.html do
          redirect_to logged_in?? @site : signup_url
        end
        format.xml  { render :xml => @site, :status => :created, :location => @site }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @site = Site.find(params[:id])

    respond_to do |format|
      if @site.update_attributes(params[:site])
        flash[:notice] = 'Site was successfully updated.'
        format.html { redirect_to(@site) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      format.html { redirect_to(sites_url) }
      format.xml  { head :ok }
    end
  end

protected
  def require_site
    return if %w( new create ).include?(params[:action])
    return if current_site.nil? or current_site.new_record?
    current_site or raise NoSiteDefinedError
  end

  def handle_no_site
    return false if %w( new create ).include?(params[:action])
    redirect_to new_site_url
  end

end
