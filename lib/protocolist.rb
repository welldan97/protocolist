require "protocolist/version"
require "protocolist/model_additions"

module Protocolist
  
  def self.fire type, options={}
    options = {:subject => @@subject, :type => type}.merge options
    @@activity_class.create options if options[:subject] && @@activity_class
  end
  
  def self.subject
    @@subject
  end
  
  def self.subject= subject
    @@subject = subject
  end
  
  def self.activity_class
    @@activity_class
  end
  
  def self.activity_class= activity_class
    @@activity_class = activity_class
  end
end
