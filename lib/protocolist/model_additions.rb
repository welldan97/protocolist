module Protocolist
  module ModelAdditions
    module ClassMethods
      def fires activity_type, options={}
        #options normalization
        fires_on = Array(options[:on] || activity_type)

        data_proc = if options[:data].respond_to?(:call)
                      lambda{|record| options[:data].call(record)}
                    elsif options[:data].class == Symbol
                      lambda{|record| record.send(options[:data]) }
                    else
                      lambda{|record| options[:data] }
                    end

        options_for_callback = options.select{|k,v| [:if, :unless].include? k }

        options_for_fire = options.reject{|k,v| [:if, :unless, :on].include? k }

        callback_proc = lambda{|record|
          record.fire activity_type, options_for_fire.merge({:data => data_proc.call(record)})
        }

        fires_on.each do |on|
          send("after_#{on.to_s}".to_sym, callback_proc, options_for_callback)
        end
      end
    end

    def self.included base
      base.extend ClassMethods
    end

    def fire activity_type, options={}
      options[:target] = self if options[:target] == nil
      options[:target] = nil if options[:target] == false

      Protocolist.fire activity_type, options
    end
  end
end
