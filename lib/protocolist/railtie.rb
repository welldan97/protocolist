module Protocolist
  class Railtie < Rails::Railtie
    initializer 'protocolist.model_additions' do
      ActiveSupport.on_load :active_record do
        include ModelAdditions
      end
    end
    initializer 'protocolist.controller_additions' do
      ActiveSupport.on_load :action_controller do
        include ControllerAdditions
      end
    end
  end
end
