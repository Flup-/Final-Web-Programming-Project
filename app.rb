require 'sinatra'
require 'sequel'
require 'open-uri'

enable :sessions

DB = Sequel.connect('sqlite://databases/logins')

get "/" do
  session[:loggedin] ||= false
  if session[:loggedin]
    @welcome = "Welcome #{session[:username]}"
    @urls = DB[:urls].where(:uid => session[:id])
    return erb :home
  end
  erb :login
end

post "/" do
  @db = DB[:logins]
  data = @db.where(:username => params[:name], :password => params[:pass])
  puts data.empty?
  if data.empty?
    @message = "Invalid Username or Password"
    return erb :login
  end

  session[:loggedin] = true
  session[:username] = params[:name]
  session[:id] = data.first[:id]

  redirect "/"
end

get "/logout" do
  session.clear
  session[:loggedin] = false
  redirect "/"
end

get "/register" do
  session[:loggedin] ||= false
  erb :register
end

post "/register" do
  @db = DB[:logins]
  @db.insert(:username => params[:username], :password => params[:password])
  erb :login
end

post "/url" do
  @dbu = DB[:urls]
  @dbu.insert(:uid => session[:id], :url => params[:url])
  redirect '/'
end

get "/delete" do
  DB[:urls].where(:uid => session[:id], :url => params[:url]).delete
  redirect "/"
end