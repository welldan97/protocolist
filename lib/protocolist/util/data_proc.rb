module Protocolist
  module Util
    module DataProc
      extend ActiveSupport::Concern
      
      module ClassMethods
        private
        
        def extract_data_proc(data)
          if data.respond_to? :call
            lambda {|o| data.call(o) }
          elsif data.is_a? Symbol
            lambda {|o| o.send(data) }
          else
            lambda {|_| data }
          end
        end
      end
    end
  end
end