module Protocolist
  module Util
    module DataProc
      extend ActiveSupport::Concern

      module ClassMethods
        private

        def extract_data_proc(data)
          if data.respond_to?(:call)
            ->(o) { data.call(o) }
          elsif data.is_a?(Symbol)
            ->(o) { o.send(data) }
          else
            ->(_) { data }
          end
        end
      end
    end
  end
end
