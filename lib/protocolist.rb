require "protocolist/version"
require "protocolist/model_additions"
require "protocolist/controller_additions"
require "protocolist/railtie" if defined? Rails


module Protocolist

  def self.fire activity_type, options={}
    options = {:subject => @@subject, :activity_type => activity_type}.merge options
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
