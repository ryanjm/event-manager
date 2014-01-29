require './lib/event_manager'
require 'bundler'

Bundler.require :default, :development

Combustion.path = 'spec/dummy'
Combustion.initialize! :active_record

require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
