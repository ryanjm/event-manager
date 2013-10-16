require './spec/spec_helper.rb'

describe ScheduleItem do
  # create
  # ask it to create todos between two dates
  describe "#todos" do
    context "biweekly" do
      before(:each) do
        params = {
          name: "Every other Monday",
          freq: "weekly",
          interval: "2",
          days_of_week: ["Mo"],
          duration: "1"
        }
        @schedule = Schedule.new
        @schedule.create(params)
        @schedule_item = ScheduleItem.new
        @schedule_item.schedule = @schedule
        # start at the beginning of March 2013
        @schedule_item.start_date = Date.new(2013,3,1)
      end

      it "creates todos between two dates" do
        start_date = Date.new(2013,3,3)
        end_date = Date.new(2013,3,28)

        todos = @schedule_item.todos(start_date,end_date,2)

        expect1 = Date.new(2013,3,4)
        expect2 = Date.new(2013,3,18)

        todos.length.should eq(2)
        todos[0].start_date.should eq(expect1)
        todos[1].start_date.should eq(expect2)
      end

      it "doesn't duplicate todos" do
        # inital search for March
        start_date = Date.new(2013,3,3)
        end_date = Date.new(2013,3,28)

        @schedule_item.todos(start_date,end_date,2)

        @schedule_item.schedule_todos.length.should eq(2)

        start_date = Date.new(2013,3,15)
        end_date = Date.new(2013,4,5)

        # another search
        @schedule_item.todos(start_date,end_date,2)
        # shouldn't build new todos
        @schedule_item.schedule_todos.length.should eq(3)

      end
    end

    context "weekly" do
      before(:each) do
        params = {
          name: "Every Monday, Wednesday, Friday",
          freq: "weekly",
          interval: "1",
          days_of_week: ["Mo","We","Fr"],
          duration: "0"
        }
        @schedule = Schedule.new
        @schedule.create(params)
        @schedule_item = ScheduleItem.new
        @schedule_item.schedule = @schedule
        # start at the beginning of March 2013
        @schedule_item.start_date = Date.new(2013,3,3)
      end

      it "creates todos between two dates" do
        start_date = Date.new(2013,3,3)
        end_date = Date.new(2013,3,17)
        
        todos = @schedule_item.todos(start_date,end_date,2)

        mo1 = Date.new(2013,3,4)
        we1 = Date.new(2013,3,6)
        fr1 = Date.new(2013,3,8)

        mo2 = Date.new(2013,3,11)
        we2 = Date.new(2013,3,13)
        fr2 = Date.new(2013,3,15)

        todos.length.should eq(6)
        todos[0].start_date.should eq(mo1)
        todos[1].start_date.should eq(we1)
        todos[2].start_date.should eq(fr1)
        todos[3].start_date.should eq(mo2)
        todos[4].start_date.should eq(we2)
        todos[5].start_date.should eq(fr2)
      end
    end
  end
end
