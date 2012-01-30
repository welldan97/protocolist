module Protocolist
  module ModelAdditions
    def fire type, options={}
      options[:object] = self if options[:object] == nil
      options[:object] = nil if options[:object] == false
      Protocolist.fire type, options
    end
  end
end
