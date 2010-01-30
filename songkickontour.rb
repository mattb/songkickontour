require 'sinatra'
require 'dm-core'
require 'model'

# Configure DataMapper to use the App Engine datastore 
DataMapper.setup(:default, "appengine://auto")

# Make sure our template can use <%=h
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
    mattb = User.create(:name => "mattb")
    trip = mattb.trips.create(:city => "Stockholm")
    gig = trip.gigs.create(:name => "someone")
    erb :index
end

get '/user/:nick' do
end
