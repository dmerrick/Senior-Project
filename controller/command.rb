# execute the command
post '/kindle/cmd' do
  
  # read command from form
  input = params[:command]

  # create a new Command and save it
  cmd = Command.create(:input => input)
  cmd.save!
  
  # show the last 10 commands in the history
  @all_commands = Command.all(:order => [:created_at.asc])[-10..-1].map{|c| c.to_s}.join
  haml :cmd
end

# show the command line interface
get '/kindle/cmd' do
  # uncomment the next line to show the history when you first navigate to this route
  #@all_commands = Command.all(:order => [:created_at.asc])[-10..-1].map{|c| c.to_s}.join
  haml :cmd
end