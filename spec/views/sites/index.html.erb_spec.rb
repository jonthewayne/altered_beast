require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sites/index.html.erb" do
  include SitesHelper
  
  before do
    #site_98 = mock_model(Site)
    #site_99 = mock_model(Site)

    assigns[:sites] = Site.paginate(:all, :page => 1) #[site_98, site_99]
  end

  it "should render list of sites" do
    render "/sites/index.html.erb"
  end
end

