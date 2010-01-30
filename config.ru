require 'appengine-rack'
AppEngine::Rack.configure_app(          
    :application => "songkick-on-tour",           
    :precompilation_enabled => true,
    :version => "1")
run lambda { Rack::Response.new("Hello").finish }
