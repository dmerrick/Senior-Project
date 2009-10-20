#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'dm-timestamps'
#require 'dm-aggregates'
require 'haml'

require 'models/definition'

configure do
  set :root, File.dirname(__FILE__)
  disable :static

  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:development.db')
  DataMapper.auto_upgrade!

  Definition.auto_upgrade!
end

get '/' do
  haml :index
end
 
post '/' do
  content = params[:content]
  raise "Nil definition" if content.empty?
  
  ip = request.env['REMOTE_ADDR'].split(",").first
  
  @def = Definition.first_or_create(:content => content, :ip => ip)
  haml :new
end

get '/random' do
  #@def = Definition.get( rand(Definition.count) + 1)
  @def = Definition.all.shuffle.first
  haml :random
end

error do
  haml :index
end
 
use_in_file_templates!

__END__
@@ layout
!!! 1.1
%html
  %head
    %title What is time?
    %link{:rel => 'stylesheet', :href => 'http://www.w3.org/StyleSheets/Core/Swiss', :type => 'text/css'}  
  %body
    = yield
    #err.warning= env['sinatra.error']
    #footer
      %br
        %a{:href => '/'}>= 'new'
        ,&nbsp;
        %a{:href => '/random'}>= 'random'
      %br
      %small &copy; DM
 
@@ index
%h1.title What is time?
%form{:method => 'post', :action => '/'}
  Time is:
  %input{:type => 'text', :name => 'content', :size => '50'} 
  %input{:type => 'submit', :value => 'submit!'}

@@ new
%h1.title Thanks for your time!
- unless @def.nil?
  = @def.content

@@ random
%h1.title Time is...
= @def.content