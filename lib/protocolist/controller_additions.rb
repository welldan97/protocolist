module Protocolist
  module ControllerAdditions
    module ClassMethods
      def fires activity_type, options={}
        #options normalization
        options[:only] ||= activity_type unless options[:except]

        data_proc = if options[:data].respond_to?(:call)
                      lambda{|controller| options[:data].call(controller)}
                    elsif options[:data].class == Symbol
                      lambda{|controller| controller.send(options[:data]) }
                    else
                      lambda{|record| options[:data] }
                    end

        options_for_callback = options.select{|k,v| [:if, :unless, :only, :except].include? k }

        options_for_fire = options.reject{|k,v| [:if, :unless, :only, :except].include? k }

        callback_proc = lambda{|controller|
          controller.fire activity_type, options_for_fire.merge({:data => data_proc.call(controller)})
        }

        send(:after_filter, callback_proc, options_for_callback)
      end


      def self.extended base
        base.send(:before_filter, :initilize_protocolist)
      end
    end

    def self.included base
      base.extend ClassMethods
    end

    def fire activity_type=nil, options={}
      options[:target] =  instance_variable_get("@#{self.controller_name.singularize}") if options[:target] == nil
      options[:target] = nil if options[:target] == false
      activity_type ||= action_name.to_sym

      Protocolist.fire activity_type, options
    end

    def initilize_protocolist
      Protocolist.subject = current_user
      Protocolist.activity_class = Activity
    end
  end
end
