require File.dirname(__FILE__) + '/../../spec_helper'

describe "/sites/show.html.erb" do
  include SitesHelper
  
  before do
    @site = mock_model(Site)

    assigns[:site] = @site
  end

  it "should render attributes in <p>" do
    render "/sites/show.html.erb"
  end
end

