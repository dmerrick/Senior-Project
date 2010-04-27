#!/usr/bin/ruby -KU

# for debugging
$DEBUG = true
require 'pp' if $DEBUG

require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-core'
require 'dm-timestamps'

require 'models/registration'
require 'models/command'


# framework configuration setup
# (runs once on startup)
configure do
  
  set :base_url, "http://kindle.doesntexist.com/"
  set :root, File.dirname(__FILE__)

  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:development.db')

  Registration.auto_upgrade!
  Command.auto_upgrade!
  DataMapper.auto_upgrade!
  
end


# helper methods are available in routes and views
helpers do
  
  # use the escape_html() with the alias h()
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
    
    # read credentials from file
    credentials = open("credentials.txt").read.split("\n").map{|c| c !~ /^#/ ? c : nil}.compact
    
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == credentials
  end
  
  # returns true if a valid cookie is on the device
  def valid_cookie?
    # FIXME: a problem with cookies is making me short-circuit this
    return true if $DEBUG
    
    cookie = request.cookies["kindle"]
    
    # attempt to look up cookie in registration DB
    reg = Registration.first(:content => cookie)
    
    if $DEBUG
      puts "Cookie: " + (cookie.nil? ? "nil" : cookie.to_s )
      puts "Registration: " + (reg.nil? ? "nil" : reg.to_s )
    end
    
    return !reg.nil?
  end
  
  # an attempt to make AppleScript a little more ruby-y
  def tell_iTunes_to( command )
    return "osascript -e 'tell application \"iTunes\" to " + command + "'"
  end
  
end


# define the routes
load 'routes/debug.rb' if $DEBUG
load 'routes/nonkindle.rb'
load 'routes/kindle.rb'

