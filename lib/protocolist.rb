require 'active_support'

require 'protocolist/version'
require 'protocolist/model_additions'
require 'protocolist/controller_additions'

require 'protocolist/railtie' if defined? Rails


module Protocolist

  def self.fire(activity_type, options = {})
    options = { actor: @actor, activity_type: activity_type }.merge options
    @activity_class.try(:create, options) if options[:actor]
  end
  
  class << self
    attr_accessor :actor, :activity_class
  end
end
