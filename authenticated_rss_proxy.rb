require 'rubygems'
require 'mongrel'
require 'net/http'
require 'cgi'

HOSTNAME='your basecamp url'

class SimpleHandler < Mongrel::HttpHandler
  def process(request, response)
    params = CGI::parse(request.params["QUERY_STRING"])
    response.start(200) do |head,out|
      head["Content-Type"] = "application/xml" 
      Net::HTTP.start(HOSTNAME) do |http|
        req = Net::HTTP::Get.new(params["url"].first)
        req.basic_auth params["user"].first, params["password"].first
        response = http.request(req)
        out.write response.body
      end
    end
  end
end

h = Mongrel::HttpServer.new("0.0.0.0", "9898")
h.register("/feed", SimpleHandler.new)
h.run.join
