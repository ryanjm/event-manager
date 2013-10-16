require './spec/spec_helper.rb'
# should be able to ask when the next occurance of that scheudle is, after a given date
# given ScheduleItems, should be able to find if a scheduleItem is already created for an occurance (and structure) 

# should handle if the options are invalid (crossing weekly, modifiers cross)

describe Schedule do
  describe "#convert_by_day" do
    before(:each) do
      @schedule = Schedule.new
    end

    it "takes an one day and returns a simple string" do
      days = ["Mo"]
      r = @schedule.convert_by_day(days)
      r.should eq('mo')
    end
    it "takes an multiple days and returns a simple string" do
      days = ["Mo","We"]
      r = @schedule.convert_by_day(days)
      r.should eq('mo,we')
    end
    it "should handle an offset" do
      days = ["Mo","We"]
      r = @schedule.convert_by_day(days,'2')
      r.should eq('2mo,2we')
    end
  end

  describe "#create" do
    it "takes simple hash of arguments for weekly" do
      params = {
        name: "Every other Monday",
        freq: "weekly",
        interval: "2",
        days_of_week: ["Mo"],
        duration: "1"
      }
      s = Schedule.new
      s.create(params)
      s.name.should eq("Every other Monday")
      s.freq.should eq(:weekly)
      s.interval.should eq(2)
      s.by_day.should eq('mo')
      s.duration.should eq(1) 
    end
    it "takes a hash for a monthly schedule" do
      params = {
        name: "2nd Monday each month",
        freq: "monthly",
        interval: "1",
        days_of_week: ["Mo"],
        days_of_week_offset: "2",
        duration: "0"
      }
      s = Schedule.new
      s.create(params)
      s.name.should eq("2nd Monday each month")
      s.freq.should eq(:monthly)
      s.interval.should eq(1)
      s.by_day.should eq('2mo')
      s.duration.should eq(0) 
    end
    it "takes a hash for a complex monthly schedule" do
      params = {
        name: "2nd Monday each month",
        freq: "monthly",
        interval: "1",
        days_of_week: ["Mo","We"],
        days_of_week_offset: "2",
        duration: "0"
      }
      s = Schedule.new
      s.create(params)
      s.name.should eq("2nd Monday each month")
      s.freq.should eq(:monthly)
      s.interval.should eq(1)
      s.by_day.should eq('2mo,2we')
      s.duration.should eq(0) 
    end
    it "takes a hash for days of month schedule" do
      params = {
        name: "2nd Monday each month",
        freq: "monthly",
        interval: "1",
        days_of_month: ["2"],
        duration: "0"
      }
      s = Schedule.new
      s.create(params)
      s.name.should eq("2nd Monday each month")
      s.freq.should eq(:monthly)
      s.interval.should eq(1)
      s.by_day.should eq(nil)
      s.by_month_day.should eq('2')
      s.duration.should eq(0) 
    end
    it "takes a hash for multiple days of month schedule" do
      params = {
        name: "2nd Monday each month",
        freq: "monthly",
        interval: "1",
        days_of_month: ["2","15"],
        duration: "0"
      }
      s = Schedule.new
      s.create(params)
      s.name.should eq("2nd Monday each month")
      s.freq.should eq(:monthly)
      s.interval.should eq(1)
      s.by_day.should eq(nil)
      s.by_month_day.should eq('2,15')
      s.duration.should eq(0) 
    end
  end

  describe "#valid?" do
    it "should be invalid if it is missing a name" do
      params = {
        freq: "weekly",
        interval: "1",
        days_of_week: ["Mo"],
        duration: "2"
      }
      s = Schedule.new
      s.create(params)
      s.valid?.should be_false
    end
    it "should be invalid if it is missing a freq" do
      params = {
        name: "Every Monday",
        interval: "1",
        days_of_week: ["Mo"],
        duration: "2"
      }
      s = Schedule.new
      s.create(params)
      s.valid?.should be_false
    end
    it "should be invalid if the duration is longer than the time between repetitions" do
      params = {
        name: "Every Monday",
        freq: "weekly",
        interval: "1",
        days_of_week: ["Mo"],
        duration: "8"
      }
      s = Schedule.new
      s.create(params)
      s.valid?.should be_false
    end
  end

  describe "#frequency_length" do
    it "returns 7 for weekly events" do
      params = {
        freq: "weekly",
        interval: "1",
      }
      s = Schedule.new
      s.create(params)
      s.frequency_length.should eq(7)
    end

    it "returns 14 for bi-weekly events" do
      params = {
        freq: "weekly",
        interval: "2",
      }
      s = Schedule.new
      s.create(params)
      s.frequency_length.should eq(14)
    end
  end

  describe "#first_group" do
    context "weekly" do
      before(:each) do
        params = {
          name: "Every other Monday, Wednesday, Friday",
          freq: "weekly",
          interval: "2",
          days_of_week: ["Mo", "We", "Fr"],
          duration: "1"
        }
        @s = Schedule.new
        @s.create(params)
      end

      it "returns the first group for date" do
        start_date = Date.new(2013,3,5) # First Tuesday in March
        first_group = Date.new(2013,3,4) # First Monday
        @s.first_group(start_date).should eq(first_group)
      end
    end
    # context "monthly" do
    #   before :each do
    #     params = {
    #       name: "First Monday of the Month",
    #       freq: "monthly",
    #       interval: "1",
    #       days_of_week: ["Mo"],
    #       days_of_week_offset: "1",
    #       duration: "0"
    #     }
    #     @s = Schedule.new
    #     @s.create(params)
    #   end
    #   it "returns the first group for the date" do
    #     start_date = Date.new(2013,3,5) # First Tuesday in March
    #     first_group = Date.new(2013,3,4) # First Monday
    #     @s.first_group(start_date).should eq(first_group)
    #   end
    # end

  end

  describe "#next_group" do
    context "weekly" do
      before(:each) do
        params = {
          name: "Every other Monday, Wednesday, Friday",
          freq: "weekly",
          interval: "2",
          days_of_week: ["Mo", "We", "Fr"],
          duration: "1"
        }
        @s = Schedule.new
        @s.create(params)
      end

      it "returns the first group if date is before start" do
        first_occurance = Date.new(2013,3,4) # First Monday in March
        start_search = Date.new(2013,3,3) # First Sunday
        @s.next_group(first_occurance,start_search).should eq(first_occurance)
      end

      it "returns the next group if date is after last event in week" do
        first_occurance = Date.new(2013,3,4) # First Monday in March
        start_search = Date.new(2013,3,10) # Saturday
        next_group = Date.new(2013,3,18) 
        @s.next_group(first_occurance,start_search).should eq(next_group)
      end
    end
    # context "monthly", wip: true do
    #   before(:each) do
    #     params = {
    #       name: "First Monday of Month",
    #       freq: "monthly",
    #       interval: "1",
    #       days_of_week: ["Mo"],
    #       days_of_week_offset: "1",
    #       duration: "0"
    #     }
    #     @s = Schedule.new
    #     @s.create(params)
    #   end

    #   it "returns the first group if date is before start" do
    #     first_occurance = Date.new(2013,3,4) # First Monday in March
    #     start_search = Date.new(2013,3,3) # First Sunday
    #     @s.next_group(first_occurance,start_search).should eq(first_occurance)
    #   end

    #   it "returns the next group if date is after last event in week" do
    #     first_occurance = Date.new(2013,3,4) # First Monday in March
    #     start_search = Date.new(2013,3,10) # Saturday
    #     next_group = Date.new(2013,4,1) 
    #     @s.next_group(first_occurance,start_search).should eq(next_group)
    #   end
    # end


  end

  describe "#next_date" do
    context "weekly" do
      before(:each) do
        params = {
          name: "Every other Monday, Wednesday, Friday",
          freq: "weekly",
          interval: "2",
          days_of_week: ["Mo", "We", "Fr"],
          duration: "1"
        }
        @s = Schedule.new
        @s.create(params)
      end

      it "returns next event if the start_date and after_date is before the first event" do
        # where the schedule originally starts (Sunday)
        start_date = Date.new(2013,3,10)
        # what it is expecting (first Monday after the 10th)
        first_instance = Date.new(2013,3,11)
        @s.next_date(start_date,start_date).should eq(first_instance)
      end

      it "returns date if it is a valid starting date" do
        # where to start the search (Monday)
        start_date = Date.new(2013,3,11)
        @s.next_date(start_date,start_date).should eq(start_date)
      end

      it "returns date if it is the next occurance" do
        # where to start the search (Monday)
        start_date = Date.new(2013,3,11)
        next_date = Date.new(2013,3,25)

        @s.next_date(start_date,next_date).should eq(next_date)
      end

      it "returns next occurance even if it is over a week away" do
        # Start of the month - first instance should be Monday the 4th
        start_date = Date.new(2013,3,2)
        # Start the search right after the first group (Saturday)
        after_date = Date.new(2013,3,9)
        # Should get the next instance, 2 weeks after the 4th
        expected = Date.new(2013,3,18)

        @s.next_date(start_date, after_date).should eq(expected)
      end

      it "returns next occurance even if it starts on a weird day" do
        # Start of the month - first instance is Friday the 1st
        start_date = Date.new(2013,3,1)
        # Start the search right after the first group (Saturday)
        after_date = Date.new(2013,3,2)
        # Should get the next instance, 2 weeks after the 4th
        expected = Date.new(2013,3,11)

        @s.next_date(start_date, after_date).should eq(expected)
      end

    end

    context "monthly week day schedule" do
      before(:each) do
        params = {
          name: "First Monday of the Month",
          freq: "monthly",
          interval: "1",
          days_of_week: ["Mo"],
          days_of_week_offset: "1",
          duration: "0"
        }
        @s = Schedule.new
        @s.create(params)
      end

      it "returns next event if the start_date and after_date is before the first event" do
        # where the schedule originally starts (Sunday)
        start_date = Date.new(2013,3,10)
        # what it is expecting (first Monday after the 10th)
        first_instance = Date.new(2013,4,1)
        @s.next_date(start_date,start_date).should eq(first_instance)
      end

      it "returns date if it is a valid starting date" do
        # where to start the search (Monday)
        start_date = Date.new(2013,3,4)
        @s.next_date(start_date,start_date).should eq(start_date)
      end

      it "returns date if it is the next occurance" do
        # where to start the search (Saturday)
        start_date = Date.new(2013,3,2)
        next_date = Date.new(2013,3,4)

        @s.next_date(start_date,next_date).should eq(next_date)
      end

    end

    context "monthly day schedule" do
      before :each do
        params = {
          name: "1st and 15th of the Month",
          freq: "monthly",
          interval: "1",
          days_of_month: ["1","15"],
          duration: "0"
        }
        @s = Schedule.new
        @s.create(params)
      end 

      it "returns next event if the start_date and after_date is before the first event" do
        # where the schedule originally starts (Sunday)
        start_date = Date.new(2013,2,20)
        # what it is expecting (first Monday after the 10th)
        first_instance = Date.new(2013,3,1)
        @s.next_date(start_date,start_date).should eq(first_instance)
      end

      it "returns date if it is a valid starting date" do
        # where to start the search (Monday)
        start_date = Date.new(2013,3,15)
        @s.next_date(start_date,start_date).should eq(start_date)
      end

      it "returns date if it is the next occurance" do
        # where to start the search (Saturday)
        start_date = Date.new(2013,3,2)
        next_date = Date.new(2013,3,15)

        @s.next_date(start_date,next_date).should eq(next_date)
      end

    end

  end

  describe "#next_occurrence" do
    context "basic purpose" do
      before(:each) do
        params = {
          name: "Every other Monday",
          freq: "weekly",
          interval: "2",
          days_of_week: ["Mo"],
          duration: "1"
        }
        @s = Schedule.new
        @s.create(params)
      end

      it "returns the first occurrence of an event given a date" do
        # where to start the search (March 10th is a Sunday)
        start_date = Date.new(2013,3,10)
        # what it is expecting (first Monday after the 10th)
        first_instance = Date.new(2013,3,11)

        @s.next_occurrence(start_date).should eq(first_instance)
      end

      it "returns the given date if it is a valid first occurance" do
        first_instance = Date.new(2013,3,11)

        @s.next_occurrence(first_instance).should eq(first_instance)
      end

      it "returns the first occurrence, even it if it the following week" do
        # Tuesday
        start_date = Date.new(2013,3,5)
        # the following Monday
        first_instance = Date.new(2013,3,11)

        # the true condition is for it to check the following week
        @s.next_occurrence(start_date, true).should eq(first_instance)
      end

      it "returns nil if it runs out of days to check" do
        start_date = Date.new(2013,3,5)
        @s.next_occurrence(start_date).should eq(nil)
      end
    end
    context "monthly weekday schedule" do
      before :each do
        params = {
          name: "First Monday of the Month",
          freq: "monthly",
          interval: "1",
          days_of_week: ["Mo"],
          days_of_week_offset: "1",
          duration: "0"
        }
        @s = Schedule.new
        @s.create(params)
      end

      it "returns the first occurance for monthly schedules" do
        start_date = Date.new(2013,3,2) # Saturday
        first_instance = Date.new(2013,3,4) # Monday

        @s.next_occurrence(start_date).should eq(first_instance)
      end
      it "returns the first occurance for monthly schedules - starting on the first" do
        start_date = Date.new(2013,3,1) # Friday
        first_instance = Date.new(2013,3,4) # Monday

        @s.next_occurrence(start_date, true).should eq(first_instance)
      end
      it "returns the following occurance for monthly schedules" do
        start_date = Date.new(2013,3,5) # Tuesday
        first_instance = Date.new(2013,4,1) # Monday

        @s.next_occurrence(start_date,true).should eq(first_instance)
      end
      it "returns nil if not found within month" do
        start_date = Date.new(2013,3,5) # Tuesday

        @s.next_occurrence(start_date).should eq(nil)
      end
    end
    context "monthly day schedule" do
      before :each do
        params = {
          name: "1st and 15th of the Month",
          freq: "monthly",
          interval: "1",
          days_of_month: ["1","15"],
          duration: "0"
        }
        @s = Schedule.new
        @s.create(params)
      end      
      it "returns the first occurance for a monthly day schedule" do
        start_date = Date.new(2013,3,1)
        @s.next_occurrence(start_date).should eq(start_date)
      end
      it "returns the next occurance for a monthly day schedule" do
        start_date = Date.new(2013,3,2)
        first_instance = Date.new(2013,3,15)
        @s.next_occurrence(start_date).should eq(first_instance)
      end
      it "returns the next occurance for the next month schedule" do
        start_date = Date.new(2013,3,16)
        first_instance = Date.new(2013,4,1)
        @s.next_occurrence(start_date,true).should eq(first_instance)
      end
    end
  end

  describe "#translate_by_day" do
    it "converts simple days" do
      s = Schedule.new
      s.by_day = 'mo'
      s.translate_by_day.should eq([[1,1]])
    end
    it "converts simple days multiple days" do
      s = Schedule.new
      s.by_day = 'mo,we,fr'
      s.translate_by_day.should eq([[1,1],[1,3],[1,5]])
    end
    it "converts complex days" do
      s = Schedule.new
      s.by_day = '1mo,-2we' # no an option, but handles two cases
      s.translate_by_day.should eq([[1,1],[-2,3]])
    end
  end

  describe "#first_day" do
    context "freq=:weekly" do
      it "should return first day of the week" do
        params = {
          name: "Mo, We, Fr",
          freq: "weekly",
          interval: "1",
          days_of_week: ["We","Mo","Fr"],
          duration: "1"
        }
        s = Schedule.new
        s.create(params)
        s.first_day.should eq(1)
      end
      it "should return first day of the week" do
        params = {
          name: "We, Fr",
          freq: "weekly",
          interval: "1",
          days_of_week: ["We","Fr"],
          duration: "1"
        }
        s = Schedule.new
        s.create(params)
        s.first_day.should eq(0)
      end
    end
  end

  describe "#day_of_month" do
    it "should return first day of the month - Friday" do
      s = Schedule.new
      s.day_of_month(2013,3,1,5).should eq(Date.new(2013,3,1))
    end
    it "should return first day of the month - Monday" do
      s = Schedule.new
      s.day_of_month(2013,4,1,1).should eq(Date.new(2013,4,1))
    end
    it "should return first Monday of the month" do
      s = Schedule.new
      s.day_of_month(2013,3,1,1).should eq(Date.new(2013,3,4))
    end
    it "should return first Saturday of the month" do
      s = Schedule.new
      s.day_of_month(2013,3,1,6).should eq(Date.new(2013,3,2))
    end
    it "should return second Monday of the month" do
      s = Schedule.new
      s.day_of_month(2013,3,2,1).should eq(Date.new(2013,3,11))
    end
    it "should return last Monday of the month" do
      s = Schedule.new
      s.day_of_month(2013,3,-1,1).should eq(Date.new(2013,3,25))
    end
    it "should return last day of the month" do
      s = Schedule.new
      s.day_of_month(2013,3,-1,0).should eq(Date.new(2013,3,31))
    end
    it "should return last instance of day if offset is too large" do
      s = Schedule.new
      s.day_of_month(2013,3,5,1).should eq(Date.new(2013,3,25))
    end
  end
end
