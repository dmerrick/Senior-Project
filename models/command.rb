# represents a command given on the command line
class Command
  include DataMapper::Resource
  
  property :id, Serial

  # input and output are saved permanently
  property :input, String, :length => 1024
  property :output, String, :length => 2048

  property :created_at, DateTime
  
  # here is where the command is executed
  before :save do
    # run the command and save the input
    # WARNING: VERY DANGEROUS
    begin
      self.output = `#{self.input}`
    rescue
      self.output = "ERROR\n"
    end
  end
  
  # a command-line-esque string representation
  def to_s
    "$ " + input + "\n" + output
  end
  
end
