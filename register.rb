#encoding: UTF-8
# Copyright (c) 2011 Sebastian Oliva <tian2992@gmail.com>
#Permission to use, copy, modify, and/or distribute this software for any
#purpose with or without fee is hereby granted, provided that the above
#copyright notice and this permission notice appear in all copies.

#THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
#WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
#MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
#ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
#WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
#ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
#OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
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
  property :name,      String, :length => 120, :required => true
  property :email,     String, :format => :email_address, :required => true,
    :unique => true
  property :inst,      String, :length => 30, :required => true, :default => "Ninguna"
  property :sex,       String, :length => 1

  def to_s
    "Registrar #{user_id}, #{name}"
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
#DataMapper.auto_migrate!

before do
  cache_control :public, :must_revalidate, :max_age => 60
end

get '/' do
  cache_control :max_age => 36000
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
