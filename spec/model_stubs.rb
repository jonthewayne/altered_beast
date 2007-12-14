ModelStubbing.define_models do
  time 2007, 6, 15

  model Site do
    stub :name => 'default', :host => ''
  end

  model User do
    stub :login => 'normal-user', :email => 'normal-user@example.com', :state => 'active',
      :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', :crypted_password => '00742970dc9e6319f8019fd54864d3ea740f04b1',
      :created_at => current_time - 5.days, :site => all_stubs(:site), :remember_token => 'foo-bar', :remember_token_expires_at => current_time + 5.days,
      :activation_code => '8f24789ae988411ccf33ab0c30fe9106fab32e9b', :activated_at => current_time - 4.days
  end
  
  model Forum do
    stub :name => "Default", :topics_count => 3, :posts_count => 4, :position => 0, :state => 'public', :site => all_stubs(:site)
  end
end