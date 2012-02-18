module Protocolist
  module ControllerAdditions
    module ClassMethods
      def self.extended base
        base.send(:before_filter, :initilize_protocolist)
      end
    end
    
    def self.included base
      base.extend ClassMethods
    end
    
    def fire type=nil, options={}
      options[:object] =  instance_variable_get("@#{self.controller_name.singularize}") if options[:object] == nil
      options[:object] = nil if options[:object] == false
      type ||= action_name.to_sym
      
      Protocolist.fire type, options
    end
    
    def initilize_protocolist
      Protocolist.subject = current_user
      Protocolist.activity_class = Activity
    end
  end
end
