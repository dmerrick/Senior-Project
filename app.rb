#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'

configure do
  set :root, File.dirname(__FILE__)
end

get '/?*' do
  "What is time?"
end
