class UsersController < ApplicationController
  before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge, :edit]
  before_filter :find_user, :only => [:update, :show, :edit, :suspend, :unsuspend, :destroy, :purge]
  before_filter :login_required, :only => [:settings, :update]
  
  def index
    @users = current_site.users.paginate :all, :page => current_page
  end

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    @user = current_site.users.build(params[:user])
    @user.register! if @user.valid?
    unless @user.new_record?
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  def settings
    @user = current_user
    render :action => "edit"
  end
  
  def edit
    @user = find_user
  end

  def update
    @user = admin? ? find_user : current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User account was successfully updated.'
        format.html { redirect_to(settings_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? :false : current_site.all_users.find_in_state(:first, :pending, :conditions => {:activation_code => params[:activation_code]})
    if logged_in?
      current_user.activate!
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end

  def suspend
    @user.suspend! 
    flash[:notice] = "User was suspended."
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    flash[:notice] = "User was unsuspended."
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end

protected
  def find_user
    @user = if admin?
      current_site.all_users.find_by_permalink(params[:id])
    else
      current_site.users.find_by_permalink(params[:id])
    end or raise ActiveRecord::RecordNotFound
  end
  
  def authorized?
    admin? || params[:id].blank? || @user == current_user
  end
end
