require 'protocolist/controller_additions/initializer'
require 'protocolist/util/data_proc'

module Protocolist
  module ControllerAdditions
    extend ActiveSupport::Concern
    include Initializer
    include Util::DataProc

    def fire(activity_type = nil, options = {})
      target = case options[:target]
               when nil
                 instance_variable_get("@#{controller_name.singularize}")
               when false
                 nil
               else
                 options[:target]
               end

      activity_type ||= action_name.to_sym
      options = options.merge(target: target)

      Protocolist.fire(activity_type, options)
    end

    module ClassMethods
      def fires(activity_type, options = {})
        options = options.merge(only: activity_type) unless options[:only] || options[:except]

        data_proc = extract_data_proc(options[:data])

        options_for_callback = options.slice(:if, :unless, :only, :except)
        options_for_fire     = options.except(:if, :unless, :only, :except)

        callback_proc = ->(controller; options) do
          options = options_for_fire.merge(data: data_proc.call(controller))

          controller.fire(activity_type, options)
        end

        send(:after_filter, callback_proc, options_for_callback)
      end
    end
  end
end
