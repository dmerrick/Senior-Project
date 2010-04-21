get '/nonkindle/generate/?', :agent => /^(?:(?!\bKindle\b).)*$/  do
  protected!
  
  # log the IP for security purposes
  ip = request.env['REMOTE_ADDR'].split(",").first
  reg = Registration.create(:ip => ip)
  
  @url = options.base_url + "kindle/register/" + reg.content
  
  haml :generate
end

get '/nonkindle/devices/?', :agent => /^(?:(?!\bKindle\b).)*$/  do
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

get '/nonkindle/clear_all/?', :agent => /^(?:(?!\bKindle\b).)*$/ do
  protected!
  
  unused_registrations = Registration.all(:used => false)
  
  unused_registrations.each do |reg|
    reg.destroy!
  end

  pass  
end

# the catch-all route for non-Kindles
get '/?*', :agent => /^(?:(?!\bKindle\b).)*$/  do
  protected!
  haml :non_kindle
end