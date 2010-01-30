require 'appengine-rack'

AppEngine::Rack.configure_app(          
    :application => "songkickontour",           
    :version => "1")
require 'songkickontour'

run Sinatra::Application
