require File.dirname(__FILE__) + '/../spec_helper'

describe Moderatorship do
  define_models do
    model Moderatorship do
      stub :user => all_stubs(:user), :forum => all_stubs(:forum)
    end
    
    model Site do
      stub :other, :name => 'other'
    end
    
    model Forum do
      stub :other_site, :name => "Other", :site => all_stubs(:other_site)
    end
  end

  it "adds user/forum relation" do
    forums(:other).moderators.should == []
    lambda do
      forums(:other).moderators << users(:default)
    end.should change { Moderatorship.count }.by(1)
    forums(:other).moderators(true).should == [users(:default)]
  end
  
  %w(user_id forum_id).each do |attr|
    it "requires #{attr}" do
      mod = new_moderatorship(:default)
      mod.send("#{attr}=", nil)
      mod.should_not be_valid
      mod.errors.on(attr).should_not be_nil
    end
  end
  
  it "doesn't add duplicate relation" do
    lambda do
      forums(:default).moderators << users(:default)
    end.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  it "doesn't add relation for user and forum in different sites" do
    lambda do
      forums(:other_site).moderators << users(:default)
    end.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  %w(forum user).each do |model|
    it "is cleaned up after a #{model} is deleted" do
      send(model.pluralize, :default).destroy
      lambda do
        moderatorships(:default).reload
      end.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

ModelStubbing.define_models :moderators do
  model User do
    stub :other, :login => 'other-user', :email => '@example.com'
  end

  model Moderatorship do
    stub :user => all_stubs(:user), :forum => all_stubs(:forum)
    stub :default_other, :user => all_stubs(:user), :forum => all_stubs(:other_forum)
    stub :other_default, :user => all_stubs(:other_user)
  end
end

describe Forum, "#moderators" do
  define_models :moderators

  it "finds moderators for forum" do
    forums(:default).moderators.sort_by(&:login).should == [users(:default), users(:other)]
    forums(:other).moderators.should == [users(:default)]
  end
end

describe User, "#moderated_forums" do
  define_models :moderators

  it "finds forums for users" do
    users(:default).moderated_forums.sort_by(&:name).should == [forums(:default), forums(:other)]
    users(:other).moderated_forums.should == [forums(:default)]
  end
end