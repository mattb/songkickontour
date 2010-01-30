require 'appengine-rack'
AppEngine::Rack.configure_app(          
    :application => "songkickontour",           
    #:precompilation_enabled => true,
    :version => "1")
require 'songkickontour'
run Sinatra::Application
