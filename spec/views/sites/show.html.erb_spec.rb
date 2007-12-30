require File.dirname(__FILE__) + '/../../spec_helper'

ModelStubbing.define_models :sites_controller, :copy => :stubbed, :insert => false do
  model Site do
    stub :other, :name => 'other', :host => 'other.test.host'
  end
end

describe "/sites/show.html.erb" do
  define_models :sites_controller
  include SitesHelper
  
  before do
    @site = sites(:other)

    assigns[:site] = @site
  end

  it "should render attributes in <p>" do
    render "/sites/show.html.erb"
  end
end

