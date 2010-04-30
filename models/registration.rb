class Registration
  include DataMapper::Resource
  
  property :id, Serial

  property :content, String, :default => lambda do |r, p| 
    # generate a random 6 character alphanumeric string
    (1..6).collect do
      (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr
    end.join.downcase 
  end
  
  property :ip, String
  
  property :used, Boolean, :default => false

  property :created_at, DateTime
end
