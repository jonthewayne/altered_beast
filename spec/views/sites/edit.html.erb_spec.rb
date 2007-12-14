require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sites/edit.html.erb" do
  include SitesHelper
  
  before do
    @site = mock_model(Site)
    assigns[:site] = @site
  end

  it "should render edit form" do
    render "/sites/edit.html.erb"
    
    response.should have_tag("form[action=#{site_path(@site)}][method=post]") do
    end
  end
end


