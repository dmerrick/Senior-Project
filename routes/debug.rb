# these short routes are to aid debugging on the kindle
# they're only included if $DEBUG is true

# delete the cookie off the device
get '/d' do
  cookie = request.cookies["kindle"]
  if cookie.nil?
    puts "No cookies were found on the device."
  else
    puts "Removed cookie with ID #{cookie}."
  end
  response.delete_cookie("kindle")
  
  pass
end

# print cookie data to stdout
get '/c' do
  cookie = request.cookies["kindle"]
  if cookie.nil?
    puts "No cookies were found on the device."
  else
    puts "Device has a cookie with ID #{cookie}."
  end
end

# silly route to force an error page
get '/e' do
 obvious_missing_method
end