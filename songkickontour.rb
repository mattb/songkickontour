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
    user = User.first(:name => params[:nick])
    user.dopplr_token
end
