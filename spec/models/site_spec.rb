require File.dirname(__FILE__) + '/../spec_helper'

describe Site, "#find_by_host" do
  define_models do
    model Site do
      stub :other, :name => 'other', :host => 'other.test.host'
    end
  end
  
  it "finds site by host name" do
    Site.find_by_host(sites(:other).host).should == sites(:other)
  end
  
  it "strips host name" do
    Site.find_by_host("    " + sites(:other).host + "  ").should == sites(:other)
  end
  
  it "ignores 'www.' prefix" do
    Site.find_by_host("www." + sites(:other).host + "  ").should == sites(:other)
  end
  
  it "defaults to main site for no match" do
    Site.find_by_host(sites(:other).host + "www.").should == sites(:default)
  end
  
  it "finds main site" do
    Site.main.should == sites(:default)
    Site.find_by_host('').should == sites(:default)
  end
end

describe Site, "#users" do
  define_models do
    model Site do
      stub :other, :name => 'other', :host => 'other.test.host'
    end
    
    model User do
      stub :other, :site => all_stubs(:other_site)
    end
  end
  
  it "finds only active users in the correct site" do
    sites(:default).users.sort_by(&:login).should == [users(:admin), users(:default)]
    sites(:other).users.should   == [users(:other)]
  end
  
  it "finds all users" do
    sites(:default).all_users.size.should == User.count-1
    sites(:default).all_users.should_not include(users(:other))
    
    sites(:other).all_users.should == [users(:other)]
  end
end