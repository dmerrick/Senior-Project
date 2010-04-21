class Registration
  include DataMapper::Resource
  
  property :id, Serial

  property :content, String, :default => lambda { |r, p| 
    (1..6).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join.downcase }
    
  property :ip, String
  
  property :used, Boolean, :default => false

  property :created_at, DateTime
end
