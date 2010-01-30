require 'appengine-rack'

AppEngine::Rack.configure_app(          
    :application => "songkickontour",           
    :version => "1")
require 'songkickontour'

use Rack::Cache, { :metastore   => 'gae://cache-meta', :entitystore => 'gae://cache-body' }

run Sinatra::Application
