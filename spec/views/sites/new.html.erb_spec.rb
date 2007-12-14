require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sites/new.html.erb" do
  include SitesHelper
  
  before do
    @site = mock_model(Site)
    @site.stub!(:new_record?).and_return(true)
    assigns[:site] = @site
  end

  it "should render new form" do
    render "/sites/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", sites_path) do
    end
  end
end


