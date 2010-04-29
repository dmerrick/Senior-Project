unless $DEBUG
  # the regexp for everything but the Kindle user agent
  agent = /^(?:(?!\bKindle\b).)*$/
else
  # I used Chrome in lieu of the Kindle for debugging
  agent = /^(?:(?!\bChrome\b).)*$/
end


get '/nonkindle/generate/?', :agent => agent  do
  protected!
  
  # log the IP for security purposes
  ip = request.env['REMOTE_ADDR'].split(",").first
  reg = Registration.create(:ip => ip)
  
  # generate the URL with the new Registration
  @url = options.base_url + "kindle/register/" + reg.content
  
  haml :generate
end

get '/nonkindle/devices/?', :agent => agent do
  protected!
  
  # show list of devices
  registrations = Registration.all
  
  # define a lambda to help us show unused registrations in a different color
  bool_to_color = lambda {|bool| bool ? "black" : "red"}
  colors = registrations.map{|r| r.used }.map &bool_to_color
  
  # combine the registrations with the desired colors
  @registrations_with_colors = registrations.zip(colors)
  
  haml :devices
end

get '/nonkindle/clear_all/?', :agent => agent do
  protected!
  
  unused_registrations = Registration.all(:used => false)
  
  unused_registrations.each do |reg|
    reg.destroy!
  end

  haml :devices
end

# the catch-all route for non-Kindles
get '/?*', :agent => agent do
  protected!
  haml :non_kindle
end