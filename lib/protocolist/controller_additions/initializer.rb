module Protocolist
  module ControllerAdditions
    module Initializer
      extend ActiveSupport::Concern

      included do
        before_filter :initialize_protocolist
      end

      def initialize_protocolist
        Protocolist.actor = current_user
        Protocolist.ip_address = request.remote_ip
        Protocolist.activity_class = Activity
      end
    end
  end
end
