module Protocolist
  module ModelAdditions
    module ClassMethods
      def fires type, options={}
        #options normalization
        options[:on] ||= type
        
        data_proc = if options[:data].respond_to?(:call)
                      # OPTIMIZE: AFAIK instance_eval is evil
                      lambda{|record| record.instance_eval{ options[:data].call } }
                    elsif options[:data].class == Symbol
                      lambda{|record| record.send(options[:data]) }
                    end
        
        options_for_callback = options.reject{|k,v| [:on, :data, :subject, :object].include? k }
        
        callback_proc = lambda{|record|
          if data_proc
            fire type, options.reject{|k,v|:on == k }.merge({:data => data_proc.call(record)})
          else
            fire type, options
          end
        }
        
        Array(options[:on]).each do |on|
          send("after_#{on.to_s}".to_sym, callback_proc, options_for_callback)
        end
      end
    end
    
    def self.included base
      base.extend ClassMethods
    end
    
    def fire type, options={}
      options[:object] = self if options[:object] == nil
      options[:object] = nil if options[:object] == false
      Protocolist.fire type, options
    end
  end
end
