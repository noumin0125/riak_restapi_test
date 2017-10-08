#!/usr/local/bin/ruby

require 'sinatra'
require 'sinatra/reloader'
require 'net/http'
require 'json'
require 'uri'

configure do
  BASE_URL = 'http://localhost:8098'.freeze
  BASE_BUCKETS = 'buckets/users'.freeze
end

get '/' do
  @result = JSON.parse(Net::HTTP.get(URI.parse("#{BASE_URL}/#{BASE_BUCKETS}/keys?keys=true")))
  erb :index
end

get '/user/detail/:name' do
  @name = params[:name]
  @result = JSON.parse(Net::HTTP.get(URI.parse("#{BASE_URL}/#{BASE_BUCKETS}/keys/#{@name}")))
  erb :user
end

post '/user/add' do
  payload =  {
    'team' => params[:team]
  }
  uri = URI.parse("#{BASE_URL}/#{BASE_BUCKETS}/keys/#{params[:name]}?returnbody=true")
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Post.new(uri.request_uri)
  req['Content-Type'] = 'application/json'
  req.body = payload.to_json
  http.request(req)
  redirect '/'
end

get '/user/delete/:name' do
  uri = URI.parse("#{BASE_URL}/#{BASE_BUCKETS}/keys/#{params[:name]}")
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Delete.new(uri.request_uri)
  http.request(req)
  redirect '/'
end

__END__

@@ layout
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8"/>
  <title>riak rest api test</title>
</head>
<body>
<h1>riak rest api test</h1>
<%= yield %>
</body>

@@ index
<h3>user list</h3>
<% @result["keys"].each do |value| %>
<li><a href="/user/detail/<%= value %>"><%= value %></a>:<a href="/user/delete/<%= value %>">x</a></li>
<% end %>
<hr>
<h3>user add</h3>
<form method="post" action="/user/add">
  <p>name<input type= "text" name="name"></p>
  <p>team<input type= "text" name="team"></p>
  <p><input type= "submit" value="add"></p>
</form>

@@ user
name:<%= @name %><br>
team:<%= @result['team'] %><br>
<a href="/">home</a>
