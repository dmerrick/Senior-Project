get '/kindle/register/:alphanum' do
  
  ## FIXME
  # detect agent is not a kindle, redirect somewhere

  @alphanum = params[:alphanum]
  
  # look up registration
  registration = Registration.first(:content => @alphanum)
  
  # if doesnt exist, reroute with error
  if registration.nil?
    haml :invalid_alphanum
    
  elsif registration.used
    # registration is used
    haml :registration_used
    
  else
    # mark this registration as used
    registration.used = true
    
    # save the ip address (overwriting the previous one)
    registration.ip = request.env['REMOTE_ADDR'].split(",").first
    
    # put cookie on device
    cookie = request.cookies["kindle"]
    cookie = @alphanum # formerly ||=
    response.set_cookie("kindle",
      :expires => Time.now + 60*60*24*100,
      :value => cookie,
      :secure => true
    )
    #set_cookie("kindle",cookie)
    puts "Cookie with ID #@alphanum has been placed on the device at #{registration.ip}."
    
    # save the registration
    registration.save!
    
    ## reroute to confirmation page
    haml :index
  end
  

end

# read the itunes-specific routes
load 'routes/itunes.rb'

# the only route we have for the command line (at the moment)
get '/kindle/cmd' do
  haml :cmd
end

# debug method to delete cookie off device
get '/d' do
  response.delete_cookie("kindle")
end

# the catch-all route
# either sends the user to the kindle index or redirects them
get '/?*' do  
  if has_valid_cookie?
    haml :index
  else
    haml :need_to_register
  end
end