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
    cookie ||= @alphanum
    set_cookie("kindle", cookie)
    puts "Cookie with ID #@alphanum has been placed on the device."
    
    # save the registration
    registration.save!
    
    ## reroute to confirmation page
    haml :index
  end
  

end