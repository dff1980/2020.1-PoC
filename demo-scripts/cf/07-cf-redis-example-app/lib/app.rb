require 'sinatra'
require 'redis'
require 'cf-app-utils'

before do
  unless redis_credentials
    halt(500, %{
You must bind a Redis service instance to this application.

You can run the following commands to create an instance and bind to it:

  $ cf create-service p-redis development redis-instance
  $ cf bind-service <app-name> redis-instance})
  end
end

=begin
put '/:key' do
  data = params[:data]
  if data
    redis_client.set(params[:key], data)
    status 201
    body 'success'
  else
    status 400
    body 'data field missing'
  end
end
=end

get '/' do
  globalcount = redis_client.get(params['count'])
  instance = ENV.fetch("CF_INSTANCE_INDEX", 0)
  addr = ENV.fetch("CF_INSTANCE_ADDR", "127.0.0.1")
  localcount = ENV.fetch("LOCAL_COUNT", 0)
  localcount = localcount.to_i + 1
  ENV['LOCAL_COUNT']=localcount.to_s
  globalcount = globalcount.to_i + 1
  redis_client.set(params['count'], globalcount)
  %{
    <h1>Instance #{instance} Redis example</h1>
    <h2>I am running at #{addr}</h2>
    <h3>
    Local Count #{localcount} <br>
    Global Count #{globalcount}
    </h3>
  }
end

=begin
get '/:key' do
  value = redis_client.get(params[:key])
  if value
    status 200
    body value
  else
    status 404
    body 'key not present'
  end
end

get '/config/:item' do
  unless params[:item]
    status 400
    body 'USAGE: GET /config/:item'
    return
  end

  value = redis_client.config('get', params[:item])
  if value.length < 2
    status 404
    body "config item #{params[:item]} not found"
    return
  end

  status 200
  body value[1]
end

delete '/:key' do
  result = redis_client.del(params[:key])
  if result > 0
    status 200
    body 'success'
  else
    status 404
    body 'key not present'
  end
end

get '/tls/v1/:key' do
  get_key_with_tls_version(params[:key], 'TLSv1')
end

get '/tls/v1.1/:key' do
  get_key_with_tls_version(params[:key], 'TLSv1_1')
end

get '/tls/v1.2/:key' do
  get_key_with_tls_version(params[:key], 'TLSv1_2')
end

def get_key_with_tls_version(key, version)
  begin
    value = redis_client_tls(version).get(key)
    if value
      status 200
      body value
    else
      status 404
      body 'key not present'
    end
  rescue StandardError => e
      status 418
      body 'protocol not supported: '+e.message
  end
end

=end

def redis_client_tls(version='TLSv1')
  @client ||= Redis.new(
    host: redis_credentials.fetch('host'),
    port: redis_credentials.fetch('tls_port'),
    password: redis_credentials.fetch('password'),
    ssl: true,
    ssl_params: {
      ssl_version: version,
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    },
    timeout: 30
  )
end

def redis_client
    tls_enabled = ENV['tls_enabled'] || false

    if tls_enabled
      @client ||= Redis.new(
        host: redis_credentials.fetch('host'),
        port: redis_credentials.fetch('tls_port'),
        password: redis_credentials.fetch('password'),
        ssl: true,
        timeout: 30
      )
    else
      @client ||= Redis.new(
        host: redis_credentials.fetch('host'),
        port: redis_credentials.fetch('port'),
        password: redis_credentials.fetch('password'),
        timeout: 30
      )
    end
end

def redis_credentials
  service_name = ENV['service_name'] || "redis"

  if ENV['VCAP_SERVICES']
    all_pivotal_redis_credentials = CF::App::Credentials.find_all_by_all_service_tags(['redis', 'pivotal'])
    if all_pivotal_redis_credentials && all_pivotal_redis_credentials.first
      all_pivotal_redis_credentials && all_pivotal_redis_credentials.first
    else
      redis_service_credentials = CF::App::Credentials.find_by_service_name(service_name)
      redis_service_credentials
    end
  end
end