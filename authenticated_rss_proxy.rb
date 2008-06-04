
require 'rubygems'
require 'mongrel'
require 'net/http'

HOSTNAME='your basecamp url'

class SimpleHandler < Mongrel::HttpHandler
  def process(request, response)
    params = {}
    request.params["QUERY_STRING"].split('&').each do |param|
      param = param.split('=')
      params[param[0]] = param[1]
    end
    response.start(200) do |head,out|
      head["Content-Type"] = "application/xml" 
      Net::HTTP.start(HOSTNAME) do |http|
        req = Net::HTTP::Get.new(params["url"])
        req.basic_auth params["user"], params["password"]
        response = http.request(req)
        out.write response.body
      end
    end
  end
end

h = Mongrel::HttpServer.new("0.0.0.0", "9898")
h.register("/feed", SimpleHandler.new)
h.run.join
