ActionController::Routing::Routes.draw do |map|
  map.resources :sites, :moderatorships

  map.resources :forums, :has_many => :posts do |forum|
    forum.resources :topics do |topic|
      topic.resources :posts
      topic.resource :monitorship
    end
    forum.resources :posts
  end
  
  map.resources :posts, :collection => {:search => :get}

  map.resources :users, :member => { :suspend   => :put,
                                     :unsuspend => :put,
                                     :purge     => :delete },
                        :has_many => [:posts]

  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate', :activation_code => nil
  map.signup   '/signup',                    :controller => 'users',    :action => 'new'
  map.login    '/login',                     :controller => 'sessions', :action => 'new'
  map.logout   '/logout',                    :controller => 'sessions', :action => 'destroy'
  map.resource  :session
  map.root :controller => 'forums', :action => 'index'
end
