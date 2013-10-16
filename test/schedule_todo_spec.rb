require './spec/spec_helper.rb'

describe ScheduleTodo do
  describe "#=" do
    it "should return true for two objects that have the same date, schedule_item, and inspection_structure" do
      today = Date.new
      schedule = ScheduleItem.new
      
      todo1 = ScheduleTodo.new
      todo1.schedule_item = schedule
      todo1.start_date = today
      todo1.inspection_structure_id = 4

      todo2 = ScheduleTodo.new
      todo2.schedule_item = schedule
      todo2.start_date = today
      todo2.inspection_structure_id = 4

      todo1.should eq(todo2)
    end

    it "should return false for two objects that don't have the same date, schedule_item, and inspection_structure" do
      today = Date.new
      schedule = ScheduleItem.new
      
      todo1 = ScheduleTodo.new
      todo1.schedule_item = schedule
      todo1.start_date = today
      todo1.inspection_structure_id = 4

      todo2 = ScheduleTodo.new
      todo2.schedule_item = schedule
      todo2.start_date = (today + 1)
      todo2.inspection_structure_id = 4

      todo1.should_not eq(todo2)
    end
  end
end
