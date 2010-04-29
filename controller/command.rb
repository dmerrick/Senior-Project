# execute the command
post '/kindle/cmd' do
  
  # read command from form
  input = params[:command]
  
  # if the user inputs clear, delete the history
  if input == "clear"
    Command.all.map{|c| c.destroy!}
    
    @all_commands = "$ clear\nHistory cleared."
    haml :cmd
  else
    # create a new Command and save it
    cmd = Command.create(:input => input)
    cmd.save!

    # show the last 10 commands in the history...
    commands = Command.all(:order => [:created_at.asc])[-10..-1].map{|c| c.to_s}.join
    
    # ... but truncate them to fit in the (19 line) window
    commands_array = commands.split("\n")
    if commands_array.size > 19
      @all_commands = commands_array[-19..-1].join("\n")
    else
      @all_commands = commands
    end
    
    haml :cmd  
  end

end

# show the command line interface
get '/kindle/cmd' do
  # uncomment the next line to show the history when you first navigate to this route
  #@all_commands = Command.all(:order => [:created_at.asc])[-10..-1].map{|c| c.to_s}.join
  haml :cmd
end