require './lib/event_manager/schedule.rb'

def make_dates(dates)
  dates.map {|d| DateTime.new(2013,d[0],d[1]) }
end

def test_schedule(params,opts,tests)
  # Create a new schedule
  schedule = Schedule.new
  schedule.create(params)

  # Create the events
  events = schedule.events_between(opts[:start_search], opts[:end_search])
  
  # Get the dates from the hashes
  start_dates = events.map { |i| i[:start_date] }
  end_dates = events.map{ |i| i[:end_date] }

  # Get the dates from the tests hash
  s_dates = make_dates(tests[:start_dates])
  e_dates = make_dates(tests[:end_dates])

  # Test the Schedule
  start_dates.should eq(s_dates)
  end_dates.should eq(e_dates) 
end
