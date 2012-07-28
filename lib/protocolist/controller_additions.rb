require 'protocolist/controller_additions/initializer'

module Protocolist
  module ControllerAdditions
    extend ActiveSupport::Concern
    include Initializer
    
    def fire(activity_type = nil, options = {})
      options[:target] = instance_variable_get("@#{controller_name.singularize}") if options[:target] == nil
      options[:target] = nil if options[:target] == false
      activity_type ||= action_name.to_sym

      Protocolist.fire(activity_type, options)
    end
    
    module ClassMethods
      def fires(activity_type, options = {})
        options[:only] ||= activity_type unless options[:except]

        data_proc = extract_data_proc options[:data]

        options_for_callback = options.slice(:if, :unless, :only, :except)
        options_for_fire     = options.except(:if, :unless, :only, :except)

        callback_proc = lambda do |controller|
          controller.fire(activity_type, options_for_fire.merge(:data => data_proc.call(controller)))
        end

        send(:after_filter, callback_proc, options_for_callback)
      end
      
      private
      
      def extract_data_proc(data)
        if data.respond_to? :call
          lambda {|controller| data.call(controller) }
        elsif data.is_a? Symbol
          lambda {|controller| controller.send(data) }
        else
          lambda {|record| data }
        end
      end
    end
  end
end
