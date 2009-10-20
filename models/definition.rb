class Definition
  include DataMapper::Resource

  property :id, Serial

  property :content, String
  property :ip, String

  property :created_at, DateTime

end
