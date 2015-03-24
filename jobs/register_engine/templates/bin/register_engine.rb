#!/usr/bin/env ruby
require 'net/http'
require 'json'

@sy_scheme = ENV['SHIPYARD_SCHEME']
@sy_port = ENV['SHIPYARD_PORT']
@sy_host = ENV['SHIPYARD_HOST']

@sy_controller = "#{@sy_scheme}://#{@sy_host}:#{@sy_port}"

def instance_id()
  uri = URI("http://169.254.169.254/latest/meta-data/instance-id")
  Net::HTTP.get_response(uri)
end

def local_addr()
  uri = URI("http://169.254.169.254/latest/meta-data/local-ipv4")
  Net::HTTP.get_response(url)
end

def login(username, password)

  body = {
    username: username,
    password: password
  }

  res = post "#{@sy_controller}/auth/login", {}, body.to_json
  return res["auth_token"]
end

def service_key(auth)
  res = post "#{@sy_controller}/api/servicekeys", { "X-Access-Token" => "admin:#{auth}" }, {}.to_json
  return res["key"]
end

def register(svc_key, id, host_address)
  payload = {
    engine: {
      id: id,
      address: host_address,
      cpus: 4.0,
      memory: 8192,
      labels: ['local', 'dev']
    }
  }

  res = post "#{@sy_controller}/api/engines",  { "X-Service-Key" => svc_key }, payload.to_json
end

def post(uri, headers, body)

  uri = URI(uri)

  req = Net::HTTP::Post.new(uri)
  req.content_type = 'application/json'

  headers.each { |k,v|
    req[k] = v
  }

  req.body = body

  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') { |http|
    res = http.request(req)

    return {} if res.code.to_i > 400
    res_body = nil
    res_body = JSON.parse(res.body) if !res.body.nil?

    return { code: res.code, body: res.body }
  }

end

success = false
while !success do

  begin

    auth = login('admin', 'shipyard').body
    svc_key = service_key(auth).body

    res = register svc_key, get_instance_id, local_addr
    success = true if res.code.to_i == 201

  rescue; end
end
