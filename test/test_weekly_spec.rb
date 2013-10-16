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

describe "Weekly Schedules" do
  context "Weekly" do
    it "should handle every Monday" do
      test_schedule({
        freq: 'weekly',
        interval: '1',
        days_of_week: ['Mo'],
        duration: '0'
      },{
        start_schedule: Date.new(2013,3,1),
        start_search: Date.new(2013,3,5),
        end_search: Date.new(2013,3,25)
      },{
        start_dates: [[3,11],[3,18],[3,25]],
        end_dates: [[3,11],[3,18],[3,25]]
      })
    end

    it "should handle every Wednesday-Thursday" do
      test_schedule({
        freq: 'weekly',
        interval: '1',
        days_of_week: ['We'],
        duration: '1'
      },{
        start_schedule: Date.new(2013,3,1),
        start_search: Date.new(2013,3,5),
        end_search: Date.new(2013,3,25)
      },{
        start_dates: [[3,6],[3,13],[3,20]],
        end_dates: [[3,7],[3,14],[3,21]]
      })
    end

    it "should handle every Monday, Wednesday" do
      test_schedule({
        freq: 'weekly',
        interval: '1',
        days_of_week: ['Mo','We'],
        duration: '0'
      },{
        start_schedule: Date.new(2013,3,1),
        start_search: Date.new(2013,3,5),
        end_search: Date.new(2013,3,25)
      },{
        start_dates: [[3,6],[3,11],[3,13],[3,18],[3,20],[3,25]],
        end_dates: [[3,6],[3,11],[3,13],[3,18],[3,20],[3,25]]
      })
    end
  end

  context "Bi-Weekly" do
    it "should handle every Monday, Wednesday" do
      test_schedule({
        freq: 'weekly',
        interval: '2',
        days_of_week: ['Mo','We'],
        duration: '0'
      },{
        start_schedule: Date.new(2013,3,1),
        start_search: Date.new(2013,3,5),
        end_search: Date.new(2013,3,25)
      },{
        start_dates: [[3,6],[3,18],[3,20]],
        end_dates: [[3,6],[3,18],[3,20]]
      })
    end
  end
end
