#!/usr/bin/ruby -KU

require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-core'
require 'dm-timestamps'

require 'models/registration'

# largely for debug purposes
require 'pp'

configure do
  set :base_url, "http://kindle.doesntexist.com/"
  
  set :root, File.dirname(__FILE__)
  disable :static

  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:development.db')

  Registration.auto_upgrade!
  DataMapper.auto_upgrade!
end

helpers do
  
  include Rack::Utils
  alias_method :h, :escape_html
  
  # put this at the start of a route to force HTTP authentication
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Kindle Controller")
      # throw(:halt, [401, "Not authorized\n"])
      haml :non_kindle
    end
  end

  # returns true if proviced the correct credentials
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    
    # read credentials
    credentials = open("credentials.txt").read.split("\n").map{|c| c !~ /^#/ ? c : nil}.compact
    
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == credentials
  end
  
  # returns true if a valid cookie is on the device
  def check_valid_cookie!
    cookie = request.cookies["kindle"]
    
    # attempt to look up cookie in registration DB
    reg = Registration.first(:content => cookie)
    
    if reg.nil?
      haml :need_to_register
    end
  end
  
  # helper method to make AppleScript a little more ruby-y
  def tell_iTunes_to( command )
    return "osascript -e 'tell application \"iTunes\" to " + command + "'"
  end
  
end


# define the routes
load 'routes/nonkindle.rb'
load 'routes/kindle.rb'

