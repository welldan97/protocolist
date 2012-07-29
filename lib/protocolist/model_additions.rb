require 'protocolist/util/data_proc'

module Protocolist
  module ModelAdditions
    extend ActiveSupport::Concern
    include Util::DataProc
    
    def fire(activity_type, options = {})
      options[:target] = self if options[:target] == nil
      options[:target] = nil  if options[:target] == false

      Protocolist.fire activity_type, options
    end
    
    module ClassMethods
      def fires(activity_type, options = {})
        fires_on  = [*options[:on] || activity_type]
        data_proc = extract_data_proc options[:data]

        options_for_callback = options.slice(:if, :unless)
        options_for_fire     = options.except(:if, :unless, :on)

        callback_proc = lambda do |record|
          record.fire(activity_type, options_for_fire.merge(data: data_proc.call(record)))
        end

        fires_on.each do |on|
          send("after_#{on}", callback_proc, options_for_callback)
        end
      end
    end
  end
end
