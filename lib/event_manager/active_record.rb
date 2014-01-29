module EventManager::ActiveRecord
  def self.included(base)
    base.extend EventManager::ActiveRecord::ClassMethods
  end

  module ClassMethods
    def is_event_manager
      include EventManager
    end
  end
end
