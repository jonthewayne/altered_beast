# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ::NoSiteDefinedError < StandardError; end

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'e125a4be589f9d81263920581f6e4182'
  
  rescue_from NoSiteDefinedError, :with => :handle_no_site

  before_filter :require_site
  def require_site
    current_site or raise NoSiteDefinedError
  end
  
  protected
  
    def handle_no_site
      redirect_to new_site_url 
    end
end
