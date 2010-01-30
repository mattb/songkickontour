require 'appengine-apis/urlfetch'
require 'sinatra'
require 'dm-core'
require 'json'
require 'model'
require 'dopplr'

# Configure DataMapper to use the App Engine datastore 
DataMapper.setup(:default, "appengine://auto")

# Make sure our template can use <%=h
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

#BASE_URL = "http://localhost:8080/auth"
BASE_URL = "http://songkickontour.appspot.com/auth"
DOPPLR = Dopplr.new(:next_url => BASE_URL, :session => true)

get '/' do
    response['Expires'] = (Time.now + 60).httpdate
    erb :index
end

get '/dopplr' do
    redirect DOPPLR.request_url
end

get '/auth' do
    DOPPLR.token = params[:token]
    newtoken = DOPPLR.get("https://www.dopplr.com/api/AuthSubSessionToken").body
    if newtoken.match(/Token=(.*)/)
        newtoken = $1
        DOPPLR.token = newtoken
        data = JSON.parse(DOPPLR.get("https://www.dopplr.com/api/traveller_info.js").body)

        user = User.first(:name => data['traveller']['nick'])
        if !user
            user = User.create
        end

        user.name = data['traveller']['nick']
        user.dopplr_token = DOPPLR.token
        user.save
        redirect '/user/' + user.name
    end
    newtoken
end

get '/user/:nick' do
    @user = User.first(:name => params[:nick])
    DOPPLR.token = @user.dopplr_token
    trips = JSON.parse(DOPPLR.get("https://www.dopplr.com/api/future_trips_info.js").body)['trip']
    @user.trips.clear
    trips.each { |data|
        trip = @user.trips.create(:dopplr_id => data["id"])
        trip.city = data['city']['name']
        trip.lat = data['city']['latitude']
        trip.lng = data['city']['longitude']
        trip.start = DateTime.parse(data['start'])
        trip.finish = DateTime.parse(data['finish'])
        trip.save
    }
    erb :user
end

get '/trip/:id' do
    @trip = Trip.get(params[:id].to_i)
    b=AppEngine::URLFetch.fetch(@trip.gig_url).body
    @gigs=JSON.parse(b)['resultsPage']['results']['event']
    erb :trip
end
