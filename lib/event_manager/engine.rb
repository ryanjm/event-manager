require 'rails/engine'

class EventManager::Engine < Rails::Engine
  engine_name :event_manager

  ActiveSupport.on_load :active_record do
    include EventManager::ActiveRecord
  end
end
