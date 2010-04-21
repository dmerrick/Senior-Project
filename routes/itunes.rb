get '/play' do
  system tell_iTunes_to("play") 
  pass
end

get '/pause' do
  system tell_iTunes_to("pause") 
  pass
end

get '/stop' do
  system tell_iTunes_to("stop") 
  pass
end

get '/next' do
  system tell_iTunes_to("next track") 
  pass
end

get '/prev' do
  system tell_iTunes_to("previous track")
  pass
end

get '/mute' do
  system tell_iTunes_to("set mute to true") 
  pass
end

get '/unmute' do
  system tell_iTunes_to("set mute to false") 
  pass
end

get '/quit' do
  system tell_iTunes_to("quit") 
  pass
end

get '/vol_up' do
  vol = `#{tell_iTunes_to("sound volume as integer")}`
  vol = vol.to_i + 10
  system tell_iTunes_to("set sound volume to #{vol}")
  pass
end

get '/vol_down' do
  vol = `#{tell_iTunes_to("sound volume as integer")}`
  vol = vol.to_i - 10
  system tell_iTunes_to("set sound volume to #{vol}")
  pass
end

get '/status' do
  state = `#{tell_iTunes_to("player state as string")}`
  state.to_s.strip!
  track_details = "iTunes is currently #{state}"
  
  if state == "playing" then
    artist = `#{tell_iTunes_to("artist of current track as string")}`
    track  = `#{tell_iTunes_to("name of current track as string")}`
    track_details = artist.to_s + " : " + track.to_s
  end
  
  haml :status, :locals => { :track_details => track_details }
end