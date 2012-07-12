module Protocolist
  module ModelAdditions
    module ClassMethods
      def fires activity_type, options={}
        #options normalization
        fires_on = Array(options[:on] || activity_type)

        default_fields = ['_type', '_id', 'created_at', 'updated_at', 'activity_type', 'actor_type', 'actor_id', 'target_type', 'target_id']
        data_fields = (if defined? (Mongoid)
                        Protocolist.activity_class.fields.keys
                      else
                        Protocolist.activity_class.new.attributes.keys
                      end  - default_fields ).collect{|key| key.gsub(/(_type|_id)$/, '').to_sym}  # Allows polymotphic assotiations in custom data fields
        data_procs = data_fields.inject({}) do |memo, sym|
          if options[sym]
            memo[sym] = if options[sym].respond_to?(:call)
                          lambda{|record| options[sym].call(record)}
                        elsif options[sym].class == Symbol
                          lambda{|record| record.send(options[sym]) }
                        else
                          lambda{|record| options[sym] }
                        end
          end
          memo
        end

        options_for_callback = options.select{|k,v| [:if, :unless].include? k }

        options_for_fire = options.reject{|k,v| [:if, :unless, :on].include? k }

        method_name = :"fire_#{activity_type}_after_#{fires_on.join('_')}"
        define_method(method_name) do
          data_procs.each_pair {|key, val| data_procs[key] = val.call(self) }
          opts = options_for_fire.merge data_procs
          fire activity_type, opts
        end

        fires_on.each do |on|
          send(:"after_#{on}".to_sym, method_name, options_for_callback)
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
