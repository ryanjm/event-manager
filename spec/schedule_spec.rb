require './spec/spec_helper.rb'
# should be able to ask when the next occurance of that scheudle is, after a given date
# given ScheduleItems, should be able to find if a scheduleItem is already created for an occurance (and structure)

# should handle if the options are invalid (crossing weekly, modifiers cross)

class Dummy; include EventManager; end

describe EventManager do
  describe "#encode_by_day" do
    before(:each) do
      @schedule = Dummy.new
    end

    it "takes an one day and returns a simple string" do
      days = ["Mo"]
      r = @schedule.encode_by_day(days)
      r.should eq('mo')
    end
    it "takes an multiple days and returns a simple string" do
      days = ["Mo","We"]
      r = @schedule.encode_by_day(days)
      r.should eq('mo,we')
    end
    it "should handle an offset" do
      days = ["Mo","We"]
      r = @schedule.encode_by_day(days,'2')
      r.should eq('2mo,2we')
    end
  end

  describe "#create" do
    it "takes simple hash of arguments for weekly" do
      params = {
        freq: "weekly",
        interval: "2",
        days_of_week: ["Mo"],
        duration: "1"
      }
      s = Dummy.new
      s.create(params)
      s.freq.should eq(:weekly)
      s.interval.should eq(2)
      s.by_day.should eq('mo')
      s.duration.should eq(1)
    end
    it "takes a hash for a monthly schedule" do
      params = {
        freq: "monthly",
        interval: "1",
        days_of_week: ["Mo"],
        days_of_week_offset: "2",
        duration: "0"
      }
      s = Dummy.new
      s.create(params)
      s.freq.should eq(:monthly)
      s.interval.should eq(1)
      s.by_day.should eq('2mo')
      s.duration.should eq(0)
    end
    it "takes a hash for a complex monthly schedule" do
      params = {
        freq: "monthly",
        interval: "1",
        days_of_week: ["Mo","We"],
        days_of_week_offset: "2",
        duration: "0"
      }
      s = Dummy.new
      s.create(params)
      s.freq.should eq(:monthly)
      s.interval.should eq(1)
      s.by_day.should eq('2mo,2we')
      s.duration.should eq(0)
    end
    it "takes a hash for days of month schedule" do
      params = {
        freq: "monthly",
        interval: "1",
        days_of_month: ["2"],
        duration: "0"
      }
      s = Dummy.new
      s.create(params)
      s.freq.should eq(:monthly)
      s.interval.should eq(1)
      s.by_day.should eq(nil)
      s.by_month_day.should eq('2')
      s.duration.should eq(0)
    end
    it "takes a hash for multiple days of month schedule" do
      params = {
        freq: "monthly",
        interval: "1",
        days_of_month: ["2","15"],
        duration: "0"
      }
      s = Dummy.new
      s.create(params)
      s.freq.should eq(:monthly)
      s.interval.should eq(1)
      s.by_day.should eq(nil)
      s.by_month_day.should eq('2,15')
      s.duration.should eq(0)
    end
  end

  describe "#valid?" do
    it "should be invalid if it is missing a freq" do
      params = {
        interval: "1",
        days_of_week: ["Mo"],
        duration: "2"
      }
      s = Dummy.new
      s.create(params)
      expect(s.valid?).to be false
    end
    it "should be invalid if the duration is longer than the time between repetitions" do
      params = {
        freq: "weekly",
        interval: "1",
        days_of_week: ["Mo"],
        duration: "8"
      }
      s = Dummy.new
      s.create(params)
      expect(s.valid?).to be false
    end
  end

  describe "#frequency_length" do
    it "returns 7 for weekly events" do
      params = {
        freq: "weekly",
        interval: "1",
      }
      s = Dummy.new
      s.create(params)
      s.frequency_length.should eq(7)
    end

    it "returns 14 for bi-weekly events" do
      params = {
        freq: "weekly",
        interval: "2",
      }
      s = Dummy.new
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
        @s = Dummy.new
        @s.create(params)
      end

      it "returns the first group for date" do
        event_start = DateTime.new(2013,3,5) # First Tuesday in March
        first_group = DateTime.new(2013,3,4) # First Monday
        @s.first_group(event_start).should eq(first_group)
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
    #     @s = Dummy.new
    #     @s.create(params)
    #   end
    #   it "returns the first group for the date" do
    #     event_start = DateTime.new(2013,3,5) # First Tuesday in March
    #     first_group = DateTime.new(2013,3,4) # First Monday
    #     @s.first_group(event_start).should eq(first_group)
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
        @s = Dummy.new
        @s.create(params)
      end

      it "returns the first group if date is before start" do
        first_occurance = DateTime.new(2013,3,4) # First Monday in March
        start_search = DateTime.new(2013,3,3) # First Sunday
        @s.next_group(first_occurance,start_search).should eq(first_occurance)
      end

      it "returns the next group if date is after last event in week" do
        first_occurance = DateTime.new(2013,3,4) # First Monday in March
        start_search = DateTime.new(2013,3,10) # Saturday
        next_group = DateTime.new(2013,3,18)
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
    #     @s = Dummy.new
    #     @s.create(params)
    #   end

    #   it "returns the first group if date is before start" do
    #     first_occurance = DateTime.new(2013,3,4) # First Monday in March
    #     start_search = DateTime.new(2013,3,3) # First Sunday
    #     @s.next_group(first_occurance,start_search).should eq(first_occurance)
    #   end

    #   it "returns the next group if date is after last event in week" do
    #     first_occurance = DateTime.new(2013,3,4) # First Monday in March
    #     start_search = DateTime.new(2013,3,10) # Saturday
    #     next_group = DateTime.new(2013,4,1)
    #     @s.next_group(first_occurance,start_search).should eq(next_group)
    #   end
    # end


  end

  describe "#next_event_after" do
    context "weekly" do
      before(:each) do
        params = {
          name: "Every other Monday, Wednesday, Friday",
          freq: "weekly",
          interval: "2",
          days_of_week: ["Mo", "We", "Fr"],
          duration: "1"
        }
        @s = Dummy.new
        @s.create(params)
      end

      it "returns next event if the event_start and after_date is before the first event" do
        # where the schedule originally starts (Sunday)
        @s.event_start = DateTime.new(2013,3,10)
        # what it is expecting (first Monday after the 10th)
        first_instance = DateTime.new(2013,3,11)
        @s.next_event_after(@s.event_start).should eq(first_instance)
      end

      it "returns date if it is a valid starting date" do
        # where to start the search (Monday)
        @s.event_start = DateTime.new(2013,3,11)
        @s.next_event_after(@s.event_start).should eq(@s.event_start)
      end

      it "returns date if it is the next occurance" do
        # where to start the search (Monday)
        @s.event_start = DateTime.new(2013,3,11)
        next_date = DateTime.new(2013,3,25)

        @s.next_event_after(next_date).should eq(next_date)
      end

      it "returns next occurance even if it is over a week away" do
        # Start of the month - first instance should be Monday the 4th
        @s.event_start = DateTime.new(2013,3,2)
        # Start the search right after the first group (Saturday)
        after_date = DateTime.new(2013,3,9)
        # Should get the next instance, 2 weeks after the 4th
        expected = DateTime.new(2013,3,18)

        @s.next_event_after(after_date).should eq(expected)
      end

      it "returns next occurance even if it starts on a weird day" do
        # Start of the month - first instance is Friday the 1st
        @s.event_start = DateTime.new(2013,3,1)
        # Start the search right after the first group (Saturday)
        after_date = DateTime.new(2013,3,2)
        # Should get the next instance, 2 weeks after the 4th
        expected = DateTime.new(2013,3,11)

        @s.next_event_after(after_date).should eq(expected)
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
        @s = Dummy.new
        @s.create(params)
      end

      it "returns next event if the event_start and after_date is before the first event" do
        # where the schedule originally starts (Sunday)
        @s.event_start = DateTime.new(2013,3,10)
        # what it is expecting (first Monday after the 10th)
        first_instance = DateTime.new(2013,4,1)
        @s.next_event_after(@s.event_start).should eq(first_instance)
      end

      it "returns date if it is a valid starting date" do
        # where to start the search (Monday)
        @s.event_start = DateTime.new(2013,3,4)
        @s.next_event_after(@s.event_start).should eq(@s.event_start)
      end

      it "returns date if it is the next occurance" do
        # where to start the search (Saturday)
        @s.event_start = DateTime.new(2013,3,2)
        next_date = DateTime.new(2013,3,4)

        @s.next_event_after(next_date).should eq(next_date)
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
        @s = Dummy.new
        @s.create(params)
      end

      it "returns next event if the event_start and after_date is before the first event" do
        # where the schedule originally starts (Sunday)
        @s.event_start = DateTime.new(2013,2,20)
        # what it is expecting (first Monday after the 10th)
        first_instance = DateTime.new(2013,3,1)
        @s.next_event_after(@s.event_start).should eq(first_instance)
      end

      it "returns date if it is a valid starting date" do
        # where to start the search (Monday)
        @s.event_start = DateTime.new(2013,3,15)
        @s.next_event_after(@s.event_start).should eq(@s.event_start)
      end

      it "returns date if it is the next occurance" do
        # where to start the search (Saturday)
        @s.event_start = DateTime.new(2013,3,2)
        next_date = DateTime.new(2013,3,15)

        @s.next_event_after(next_date).should eq(next_date)
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
        @s = Dummy.new
        @s.create(params)
      end

      it "returns the first occurrence of an event given a date" do
        # where to start the search (March 10th is a Sunday)
        event_start = DateTime.new(2013,3,10)
        # what it is expecting (first Monday after the 10th)
        first_instance = DateTime.new(2013,3,11)

        @s.next_occurrence(event_start).should eq(first_instance)
      end

      it "returns the given date if it is a valid first occurance" do
        first_instance = DateTime.new(2013,3,11)

        @s.next_occurrence(first_instance).should eq(first_instance)
      end

      it "returns the first occurrence, even it if it the following week" do
        # Tuesday
        event_start = DateTime.new(2013,3,5)
        # the following Monday
        first_instance = DateTime.new(2013,3,11)

        # the true condition is for it to check the following week
        @s.next_occurrence(event_start, true).should eq(first_instance)
      end

      it "returns nil if it runs out of days to check" do
        event_start = DateTime.new(2013,3,5)
        @s.next_occurrence(event_start).should eq(nil)
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
        @s = Dummy.new
        @s.create(params)
      end

      it "returns the first occurance for monthly schedules" do
        event_start = DateTime.new(2013,3,2) # Saturday
        first_instance = DateTime.new(2013,3,4) # Monday

        @s.next_occurrence(event_start).should eq(first_instance)
      end
      it "returns the first occurance for monthly schedules - starting on the first" do
        event_start = DateTime.new(2013,3,1) # Friday
        first_instance = DateTime.new(2013,3,4) # Monday

        @s.next_occurrence(event_start, true).should eq(first_instance)
      end
      it "returns the following occurance for monthly schedules" do
        event_start = DateTime.new(2013,3,5) # Tuesday
        first_instance = DateTime.new(2013,4,1) # Monday

        @s.next_occurrence(event_start,true).should eq(first_instance)
      end
      it "returns nil if not found within month" do
        event_start = DateTime.new(2013,3,5) # Tuesday

        @s.next_occurrence(event_start).should eq(nil)
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
        @s = Dummy.new
        @s.create(params)
      end
      it "returns the first occurance for a monthly day schedule" do
        event_start = DateTime.new(2013,3,1)
        @s.next_occurrence(event_start).should eq(event_start)
      end
      it "returns the next occurance for a monthly day schedule" do
        event_start = DateTime.new(2013,3,2)
        first_instance = DateTime.new(2013,3,15)
        @s.next_occurrence(event_start).should eq(first_instance)
      end
      it "returns the next occurance for the next month schedule" do
        event_start = DateTime.new(2013,3,16)
        first_instance = DateTime.new(2013,4,1)
        @s.next_occurrence(event_start,true).should eq(first_instance)
      end
    end
    context "monthly day schedule for shorter months" do
      before :each do
        params = {
          name: "30th of the Month",
          freq: "monthly",
          interval: "1",
          days_of_month: ["30"],
          duration: "0"
        }
        @s = Dummy.new
        @s.create(params)
      end
      it "returns the nil if date doesn't exist in current month" do
        event_start = DateTime.new(2015,2,1)
        @s.next_occurrence(event_start).should eq(nil)
      end
      it "returns the next month if date doesn't exist in current month and continue is true" do
        event_start = DateTime.new(2015,2,1)
        first_instance = DateTime.new(2015,3,30)
        @s.next_occurrence(event_start, true).should eq(first_instance)
      end
    end
  end

  describe "#decode_by_day" do
    it "converts simple days" do
      s = Dummy.new
      s.by_day = 'mo'
      s.decode_by_day.should eq([[1,1]])
    end
    it "converts simple days multiple days" do
      s = Dummy.new
      s.by_day = 'mo,we,fr'
      s.decode_by_day.should eq([[1,1],[1,3],[1,5]])
    end
    it "converts complex days" do
      s = Dummy.new
      s.by_day = '1mo,-2we' # no an option, but handles two cases
      s.decode_by_day.should eq([[1,1],[-2,3]])
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
        s = Dummy.new
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
        s = Dummy.new
        s.create(params)
        s.first_day.should eq(0)
      end
    end
  end

  describe "#day_of_month" do
    it "should return first day of the month - Friday" do
      s = Dummy.new
      s.day_of_month(2013,3,1,5).should eq(DateTime.new(2013,3,1))
    end
    it "should return first day of the month - Monday" do
      s = Dummy.new
      s.day_of_month(2013,4,1,1).should eq(DateTime.new(2013,4,1))
    end
    it "should return first Monday of the month" do
      s = Dummy.new
      s.day_of_month(2013,3,1,1).should eq(DateTime.new(2013,3,4))
    end
    it "should return first Saturday of the month" do
      s = Dummy.new
      s.day_of_month(2013,3,1,6).should eq(DateTime.new(2013,3,2))
    end
    it "should return second Monday of the month" do
      s = Dummy.new
      s.day_of_month(2013,3,2,1).should eq(DateTime.new(2013,3,11))
    end
    it "should return last Monday of the month" do
      s = Dummy.new
      s.day_of_month(2013,3,-1,1).should eq(DateTime.new(2013,3,25))
    end
    it "should return last day of the month" do
      s = Dummy.new
      s.day_of_month(2013,3,-1,0).should eq(DateTime.new(2013,3,31))
    end
    it "should return last instance of day if offset is too large" do
      s = Dummy.new
      s.day_of_month(2013,3,5,1).should eq(DateTime.new(2013,3,25))
    end
  end

  describe "#events_between" do
    context "biweekly" do
      before(:each) do
        params = {
          freq: "weekly",
          interval: "2",
          days_of_week: ["Mo"],
          duration: "1",
          event_start: DateTime.new(2013,3,1)
        }
        @schedule = Dummy.new
        @schedule.create(params)
      end

      it "creates events between two dates" do
        event_start = DateTime.new(2013,3,3)
        end_date = DateTime.new(2013,3,28)

        events = @schedule.events_between(event_start,end_date)

        expect1 = DateTime.new(2013,3,4)
        expect2 = DateTime.new(2013,3,18)

        events.length.should eq(2)
        events[0][:start_date].should eq(expect1)
        events[1][:start_date].should eq(expect2)
      end

      it "creates events between two dates, using block" do
        event_start = DateTime.new(2013,3,3)
        end_date = DateTime.new(2013,3,28)

        expect1 = DateTime.new(2013,3,4)
        expect2 = DateTime.new(2013,3,18)
        expectations = [expect1, expect2]


        events = []
        @schedule.events_between(event_start,end_date) do |event|
          events << event
        end

        events.length.should eq(2)
        events[0][:start_date].should eq(expect1)
        events[1][:start_date].should eq(expect2)
      end

      it "creates events between two dates, with varying timezones" do
        event_start = DateTime.new(2013,3,3,0,0,0,'-6')
        end_date = DateTime.new(2013,3,28,0,0,0,'-6')

        @schedule.event_start = DateTime.new(2013,3,1,0,0,0,'-6')
        events = @schedule.events_between(event_start,end_date)

        expect1 = DateTime.new(2013,3,3,23,0,0,'-7')
        expect2 = DateTime.new(2013,3,17,23,0,0,'-7')

        events.length.should eq(2)
        events[0][:start_date].should eq(expect1)
        events[1][:start_date].should eq(expect2)
      end
    end

    context "weekly" do
      before(:each) do
        params = {
          freq: "weekly",
          interval: "1",
          days_of_week: ["Mo","We","Fr"],
          duration: "0",
          event_start: DateTime.new(2013,3,3)
        }
        @schedule = Dummy.new
        @schedule.create(params)
      end

      it "creates events between two dates" do
        event_start = DateTime.new(2013,3,3)
        end_date = DateTime.new(2013,3,17)

        events = @schedule.events_between(event_start,end_date)

        mo1 = DateTime.new(2013,3,4)
        we1 = DateTime.new(2013,3,6)
        fr1 = DateTime.new(2013,3,8)

        mo2 = DateTime.new(2013,3,11)
        we2 = DateTime.new(2013,3,13)
        fr2 = DateTime.new(2013,3,15)

        events.length.should eq(6)
        events[0][:start_date].should eq(mo1)
        events[1][:start_date].should eq(we1)
        events[2][:start_date].should eq(fr1)
        events[3][:start_date].should eq(mo2)
        events[4][:start_date].should eq(we2)
        events[5][:start_date].should eq(fr2)
      end

      it "creates events between two dates, with ad-hoc start date" do
        event_start = DateTime.new(2013,3,3)
        end_date = DateTime.new(2013,3,17)
        ad_hoc_start = DateTime.new(2013,3,5)

        events = @schedule.events_between(event_start,end_date, ad_hoc_start)

        we1 = DateTime.new(2013,3,6)
        fr1 = DateTime.new(2013,3,8)

        mo2 = DateTime.new(2013,3,11)
        we2 = DateTime.new(2013,3,13)
        fr2 = DateTime.new(2013,3,15)

        events.length.should eq(5)
        events[0][:start_date].should eq(we1)
        events[1][:start_date].should eq(fr1)
        events[2][:start_date].should eq(mo2)
        events[3][:start_date].should eq(we2)
        events[4][:start_date].should eq(fr2)
      end
    end
  end
end
