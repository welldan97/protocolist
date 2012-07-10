require "protocolist/version"
require "protocolist/model_additions"
require "protocolist/controller_additions"
require "protocolist/railtie" if defined? Rails


module Protocolist

  def self.fire activity_type, options={}
    options = {:actor => @actor, :activity_type => activity_type}.merge options
    @activity_class.create options if options[:actor] && @activity_class
  end

  def self.actor
    @actor
  end

  def self.actor= actor
    @actor = actor
  end

  def self.activity_class
    @activity_class
  end

  def self.activity_class= activity_class
    @activity_class = activity_class
  end
end
