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
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['test', 'test']
  end
  
  # returns true if a valid cookie is on the device
  def has_valid_cookie?
    
    cookie = request.cookies["kindle"]
    
    # attempt to look up cookie in registration DB
    reg = Registration.first(:content => cookie)
    
    return reg != nil
  end
  
  # helper method to make AppleScript a little more ruby-y
  def tell_iTunes_to( command )
    return "osascript -e 'tell application \"iTunes\" to " + command + "'"
  end
end


# define the routes
load 'routes/nonkindle.rb'
load 'routes/kindle.rb'


# views come after the following line
__END__
@@ layout
!!! 1.1
%html
  %head
    %title Kindle Controller
  %body
    = yield
    #err.warning= env['sinatra.error']
    #footer
      %small &copy; DM

@@ index
#{locals[:track_details]}
%br
%a{:href => '/kindle/play'}>= 'play'
\-
%a{:href => '/kindle/pause'}>= 'pause'
\-
%a{:href => '/kindle/stop'}>= 'stop'
%br
%a{:href => '/kindle/prev'}>= 'prev'
\-
%a{:href => '/kindle/next'}>= 'next'
%br
%a{:href => '/kindle/vol_up'}>= 'vol+'
\-
%a{:href => '/kindle/vol_down'}>= 'vol-'
%br
%a{:href => '/kindle/mute'}>= 'mute'
\-
%a{:href => '/kindle/unmute'}>= 'unmute'
%br
%a{:href => '/kindle/status'}>= 'show current track'
%br
%a{:href => '/kindle/quit'}>= 'quit iTunes'
%br
%a{:href => '/kindle/cmd'}>= 'show command line'

@@ cmd
%textarea
%br

@@ non_kindle
Welcome to the non-Kindle side of things!
%br
%a{:href => '/nonkindle/generate'}>= 'Add New Kindle'
%br
%a{:href => '/nonkindle/devices'}>= 'List All Registrations'
%br
%a{:href => '/nonkindle/clear_all'}>= 'Clear All Pending Registrations'

@@ generate
Please go to the following URL on your Kindle:
%br
%textarea{:cols=>@url.length, :rows=> 1}
  #{@url}
%br
%a{:href => '/nonkindle/'}>= 'Back to Home'

@@ need_to_register
Sorry, but you have to register this device.

@@ register
Your Kindle is now registered!
TODO: Actually register

@@ devices
Here is the list of existing registrations:
%ul
- @registrations_with_colors.each do |reg,color|
  %li{:style=>"color:#{color};" }= reg.ip + " : " + options.base_url + "kindle/register/" + reg.content
%br
Items in red have yet to be activated. Click&nbsp;
%a{:href => '/nonkindle/clear_all'}>= 'here'
&nbsp;to clear them.
%br
%a{:href => '/nonkindle/'}>= 'Back to Home'

@@ invalid_alphanum
Sorry, we could not find a pending Kindle registration with ID #{@alphanum}.
Please try generating a new URL.

@@ registration_used
The Kindle registration with ID #{@alphanum} has already been used.
For security reasons, please generate a new URL.
