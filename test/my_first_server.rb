require 'webrick'

server = WEBrick::HTTPServer.new :Port => 8080

server.mount_proc '/' do |req, res|
  res.content_type = 'text/html'
  res.body = req.query.to_s
end

trap('INT') { server.shutdown }
server.start

