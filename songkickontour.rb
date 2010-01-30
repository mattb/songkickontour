require 'appengine-apis/urlfetch'
require 'appengine-apis/logger'
require 'appengine-apis/labs/taskqueue'
require 'sinatra'
require 'dm-core'
require 'json'
require 'model'
require 'dopplr'

# Configure DataMapper to use the App Engine datastore 
DataMapper.setup(:default, "appengine://auto")
logger = AppEngine::Logger.new

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

get '/songkick/:nick' do
    erb :songkick
end

post '/songkick/:nick' do
    @user = User.first(:name => params[:nick])
    @user.update(:songkick_name => params[:songkick])
    redirect "/user/#{params[:nick]}"
end

get '/user/:nick' do
    @user = User.first(:name => params[:nick])
    if !@user.songkick_name
        redirect "/songkick/#{params[:nick]}"
        return
    end
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
        AppEngine::Labs::TaskQueue.add(:url => "/update_trip/#{trip.id}", :method => "GET")
    }
    erb :user
end

get '/update_trip/:id' do
    logger.error "Updating gigs for trip #{params[:id]}"
    trip = Trip.get(params[:id].to_i)
    logger.info trip.gig_url
    b=AppEngine::URLFetch.fetch(trip.gig_url).body
    gigs=JSON.parse(b)['resultsPage']['results']
    if gigs.has_key?("events")
        gigs = gigs["events"]
    else
        gigs = []
    end
    gigs.each { |data|
        gig = Gig.find_or_create_from_songkick(data)
        gig.update(:trip => trip)
        logger.warn "Found gig: " + gig.name
    }
    "OK"
end

get '/trip/:id' do
    erb :trip
end
