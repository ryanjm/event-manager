require './spec/spec_helper.rb'

#      March 2013
# Su Mo Tu We Th Fr Sa
#                 1  2
#  3  4  5  6  7  8  9
# 10 11 12 13 14 15 16
# 17 18 19 20 21 22 23
# 24 25 26 27 28 29 30
# 31
#      April 2013
# Su Mo Tu We Th Fr Sa
#     1  2  3  4  5  6
#  7  8  9 10 11 12 13
# 14 15 16 17 18 19 20
# 21 22 23 24 25 26 27
# 28 29 30

describe "Monthly Schedules" do
  context "Monthly - week days" do
    it "should handle first Monday of the month" do
      test_schedule({
        freq: 'monthly',
        interval: '1',
        days_of_week: ['Mo'],
        days_of_week_offset: "1",
        duration: '0'
      },{
        start_schedule: Date.new(2013,3,1),
        start_search: Date.new(2013,3,1),
        end_search: Date.new(2013,3,31)
      },{
        start_dates: [[3,4]],
        end_dates: [[3,4]]
      })
    end
    it "should handle second Monday of the month" do
      test_schedule({
        freq: 'monthly',
        interval: '1',
        days_of_week: ['Mo'],
        days_of_week_offset: "2",
        duration: '0'
      },{
        start_schedule: Date.new(2013,3,1),
        start_search: Date.new(2013,3,1),
        end_search: Date.new(2013,5,31)
      },{
        start_dates: [[3,11],[4,8],[5,13]],
        end_dates: [[3,11],[4,8],[5,13]]
      })
    end
    it "should handle last Monday of the month" do
      test_schedule({
        freq: 'monthly',
        interval: '1',
        days_of_week: ['Mo'],
        days_of_week_offset: "-1",
        duration: '0'
      },{
        start_schedule: Date.new(2013,3,1),
        start_search: Date.new(2013,3,1),
        end_search: Date.new(2013,5,31)
      },{
        start_dates: [[3,25],[4,29],[5,27]],
        end_dates: [[3,25],[4,29],[5,27]]
      })
    end
  end
  
  context "Monthly - month days" do
    it "should handle 1st and 15th" do
      test_schedule({
        name: "1st and 15th of the Month",
        freq: "monthly",
        interval: "1",
        days_of_month: ["1","15"],
        duration: "0"
      },{
        start_schedule: Date.new(2013,2,20),
        start_search: Date.new(2013,2,20),
        end_search: Date.new(2013,5,1)
      },{
        start_dates: [[3,1],[3,15],[4,1],[4,15],[5,1]],
        end_dates: [[3,1],[3,15],[4,1],[4,15],[5,1]]
      })
    end
    it "should handle last day of month", wip: true  do
      test_schedule({
        name: "Last of month",
        freq: "monthly",
        interval: "1",
        days_of_month: ["-1"],
        duration: "0"
      },{
        start_schedule: Date.new(2013,3,20),
        start_search: Date.new(2013,3,20),
        end_search: Date.new(2013,5,1)
      },{
        start_dates: [[3,31],[4,30]],
        end_dates: [[3,31],[4,30]]
      })
    end
  end
end
