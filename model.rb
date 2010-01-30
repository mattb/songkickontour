class User
    include DataMapper::Resource

    property :id, Serial
    property :name, String
    property :dopplr_token, String

    has n, :trips
end

class Trip
    include DataMapper::Resource

    property :id, Serial
    property :dopplr_id, Integer, :index => true
    property :city, String
    property :start, DateTime
    property :finish, DateTime
    property :lat, Float
    property :lng, Float
    property :gigs_checked_at, DateTime

    belongs_to :user
    has n, :gigs

    def check_gigs!
        lat = self.lat
        lng = self.lng
        start = self.start.to_time.strftime("%Y-%m-%d")
        finish = self.finish.to_time.strftime("%Y-%m-%d")
        url = "http://api.songkick.com/api/3.0/events.json?apikey=musichackdaystockholm&type=concert&location=geo:#{lat},#{lng}&min_date=#{start}&max_date=#{finish}"
        return url
    end
end

class Gig
    include DataMapper::Resource

    belongs_to :trip
    property :id, Serial
    property :name, String
    property :url, String
    property :start, DateTime, :index => true
    property :songkick_id, Integer, :index => true

    def Gig.find_or_create_from_songkick(data)
        gig = Gig.first(:songkick_id => data['id'])
        if gig
            return gig.update(:url => data['uri'], :start => DateTime.parse(data['start']['date'] + "T" + data['start']['time']), :name => data['displayName'])
        else
            return Gig.create(:url => data['uri'], :start => DateTime.parse(data['start']['date'] + "T" + data['start']['time']), :name => data['displayName'], :songkick_id => data['id'])
        end
    end
end
