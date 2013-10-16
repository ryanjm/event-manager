require './schedule.rb'
require './schedule_item.rb'
require './schedule_todo.rb'
require 'date'

def make_dates(dates)
  dates.map {|d| Date.new(2013,d[0],d[1]) }
end

def test_schedule(params,opts,tests)
  # Create a new schedule
  schedule = Schedule.new
  schedule.create(params)

  # Create a schedule_item
  schedule_item = ScheduleItem.new
  schedule_item.schedule = schedule
  schedule_item.start_date = opts[:start_schedule]

  # Create the todos
  # - 3 is just the inspection_id
  todos = schedule_item.todos(opts[:start_search], opts[:end_search], 3)
  
  # Get the dates from the todos
  start_dates = todos.map(&:start_date)
  end_dates = todos.map(&:end_date)

  # Get the dates from the tests hash
  s_dates = make_dates(tests[:start_dates])
  e_dates = make_dates(tests[:end_dates])

  # Test the Schedule
  start_dates.should eq(s_dates)
  end_dates.should eq(e_dates) 
end
