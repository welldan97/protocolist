require "protocolist/version"

module Protocolist

  def self.fire type, options={}
    options = {:actor => @@actor, :type => type}.merge options
    
    @@action_class.create options if options[:actor] && @@action_class
  end
  
  def self.actor
    @@actor
  end
  
  def self.actor= actor
    @@actor = actor
  end
  
  def self.action_class
    @@action_class
  end
  
  def self.action_class= action_class
    @@action_class = action_class
  end
end
