get '/kindle/play' do
  system tell_iTunes_to("play") 
  pass
end

get '/kindle/pause' do
  system tell_iTunes_to("pause") 
  pass
end

get '/kindle/stop' do
  system tell_iTunes_to("stop") 
  pass
end

get '/kindle/next' do
  system tell_iTunes_to("next track") 
  pass
end

get '/kindle/prev' do
  system tell_iTunes_to("previous track")
  pass
end

get '/kindle/mute' do
  system tell_iTunes_to("set mute to true") 
  pass
end

get '/kindle/unmute' do
  system tell_iTunes_to("set mute to false") 
  pass
end

get '/kindle/quit' do
  system tell_iTunes_to("quit") 
  pass
end

get '/kindle/vol_up' do
  vol = `#{tell_iTunes_to("sound volume as integer")}`
  vol = vol.to_i + 10
  system tell_iTunes_to("set sound volume to #{vol}")
  pass
end

get '/kindle/vol_down' do
  vol = `#{tell_iTunes_to("sound volume as integer")}`
  vol = vol.to_i - 10
  system tell_iTunes_to("set sound volume to #{vol}")
  pass
end

get '/kindle/status' do
  state = `#{tell_iTunes_to("player state as string")}`
  state.to_s.strip!
  track_details = "iTunes is currently #{state}"
  
  if state == "playing" then
    artist = `#{tell_iTunes_to("artist of current track as string")}`
    track  = `#{tell_iTunes_to("name of current track as string")}`
    track_details = artist.to_s + " : " + track.to_s
  end
  
  haml :index, :locals => { :track_details => track_details }
end