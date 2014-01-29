require 'spec_helper'

describe EventManager do
  describe "modules" do
    it "has the schedule module attached" do
      expect(Event.included_modules.include?(EventManager::Schedule)).to be true
    end
  end
end
