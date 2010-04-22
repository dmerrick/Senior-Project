#!/usr/bin/ruby -KU

require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-core'
require 'dm-timestamps'

require 'models/registration'

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
  
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Kindle Controller")
      #throw(:halt, [401, "Not authorized\n"])
      haml :non_kindle
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['test', 'test']
  end
  
  def tell_iTunes_to( command )
    return "osascript -e 'tell application \"iTunes\" to " + command + "'"
  end
end

load 'routes/kindle.rb'
load 'routes/nonkindle.rb'

# the only route we have for the command line (at the moment)
get '/kindle/cmd' do
  haml :cmd
end

load 'routes/itunes.rb'

# the catch-all route
get '/?*' do
  haml :index
end


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

@@ status
#{locals[:track_details]}
%br

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
#{@url}

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

@@ invalid_alphanum
Sorry, we could not find a pending Kindle registration with ID #{@alphanum}.
Please try generating a new URL.

@@ registration_used
The Kindle registration with ID #{@alphanum} has already been used.
For security reasons, please generate a new URL.
