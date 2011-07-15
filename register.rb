#encoding: UTF-8
require 'rubygems'
require 'sinatra'
require 'erb' # easier for beginners than haml...
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'


if ENV['DATABASE_URL'] #are we running on Heroku (or a properly configured host?)
  DataMapper.setup(:default, ENV['DATABASE_URL'])
else #so, running locally, eh?
  DataMapper::Logger.new($stdout, :debug)  
  DataMapper.setup(:default, 'sqlite:///tmp/register-test.db')
end

class Registree
  include DataMapper::Resource

  property :user_id,   Serial
  property :name,      String, :length => 120
  property :email,     String, :format => :email_address, :required => true,
    :unique => true
   
  #you can add more fields in here

  def to_s
    "Registrar #{user_id}, #{name}"
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
#DataMapper.auto_migrate!

get '/' do
  erb :index
end

get '/id/:num' do
  @registree = Registree.first(:user_id => params[:num])
  if @registree
    erb :user_info
  else
    erb :no_record
  end
end

get '/registrees' do
  all_persons = Registree.all
  return_list = ""
  for person in all_persons do
    return_list << "#{person.user_id},#{person.name},#{person.email}\n"
  end
  return return_list
end

get '/register' do
  erb :register
end

post '/register' do
  registree = Registree.new(:name=>params[:name], :email=>params[:email])
  if registree.save
    redirect "/id/#{registree.user_id}"
  else
    @error_message = "error in registration"
    erb :register
  end
end

get '/おはよ' do
  return "尾羽よ　ございます！"
end