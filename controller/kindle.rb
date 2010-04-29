get '/kindle/register/:alphanum' do
  
  @alphanum = params[:alphanum]
  
  # look up registration
  registration = Registration.first(:content => @alphanum)
  
  # if doesnt exist, reroute with error
  if registration.nil?
    haml :invalid_alphanum
    
  # reroute if the registration has been marked used
  elsif registration.used
    haml :registration_used
    
  else
    # mark this registration as used
    registration.used = true
    
    # save the ip address (overwriting the previous one)
    registration.ip = request.env['REMOTE_ADDR'].split(",").first
    
    # put cookie on device
    response.set_cookie("kindle", {
      :expiration => Time.now + 60*60*24*100,
      :domain => options.base_url.chop, # removing the trailing slash
      :path => "/kindle",
      :httponly => true,
      :value => @alphanum,
      :secure => true
    })
    
    puts "Cookie with ID #@alphanum has been placed on the device at #{registration.ip}." if $DEBUG
        
    # save the registration
    registration.save!
    
    # reroute to confirmation page
    haml :register
  end
  
end

# check cookie on all other pages starting with "/kindle"
get '/kindle/?*' do
  if valid_cookie?
    pass
  else
    haml :need_to_register
  end 
end


# read the kindle-specific route files
load 'controller/itunes.rb'
load 'controller/command.rb'


# send everything else to the kindle index
get '/?*' do
  haml :index
end