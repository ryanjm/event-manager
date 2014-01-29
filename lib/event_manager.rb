require "event_manager/schedule"

module EventManager
  include EventManager::Schedule
end

require "event_manager/version"
require "event_manager/active_record"
require "event_manager/engine"

