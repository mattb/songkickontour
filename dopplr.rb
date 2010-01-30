require 'googleauthsub'

include GData
class Dopplr < GoogleAuthSub
    def request_url
        #raise AuthSubError, "Invalid next URL: #{@next_url}" if !full_url?(@next_url)
        #raise AuthSubError, "Invalid scope URL: #{@scope}" if !full_url?(@scope)
        @scope ||= "http://www.dopplr.com"
        query = "next=" << @next_url << "&scope=" << @scope << "&session="<<
        (session_token? ? '1' : '0')<< "&secure="<< (secure_token? ? '1' : '0')
        query = URI.encode(query)
        URI::HTTPS.build({:host => "www.dopplr.com", :path => "/api/AuthSubRequest", :query => query })
    end
end
