class UsersController < ApplicationController
  before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:update, :show, :suspend, :unsuspend, :destroy, :purge]
  before_filter :login_required, :only => [:edit, :update]
  
  def index
    @users = current_site.users.paginate :all, :page => current_page
  end

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    @user = current_site.users.build(params[:user])
    raise ActiveRecord::RecordInvalid.new(@user) unless @user.valid?
    @user.register!
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def edit
    if params[:id]
      redirect_to settings_path and return
    end
    @user = current_user
  end

  def update
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Forum was successfully updated.'
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
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
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
    @user = current_site.users.find_by_permalink(params[:id])
  end
  
  def authorized?
    params[:id].blank? || @user == current_user
  end
end
