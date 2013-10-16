# Encoding is heavely based off of ICS format
# http://www.ietf.org/rfc/rfc2445.txt
# 4.3.10 Recurrence Rule
# It is HIGHLY suggested to read through the entire section before reading this code. By sticking closely to the ICS format, we should be able to easily expand out the options if we want to handle more cases.
#
# duration - ics assumes start/end dates to figure out how long an event should be and how to repeat it. I'm changing it a little by having a duration in days. My approach is for the schedule to define when something is DUE, and then duration should be how many days the inspector has to do it. I think the due date is more important then when it should be started.
 
class Schedule

  attr_accessor :id
  attr_accessor :name
  attr_accessor :freq # identifies type of recurrance (required)
  attr_accessor :interval # how often to repeat (positive value, default = 1)
  attr_accessor :by_day # list of days, with possible value in front
  attr_accessor :by_month_day # integer representing day in month
  # attr_accessor :by_week_no # integer representing week in year
  # attr_accessor :by_month # integer representing mo in year
  attr_accessor :wkst # defines when the week starts (defaults to Monday) - can't currently change
  attr_accessor :duration # breaking from ics a little here (see above)

  # set the defaults
  def initialize
    @interval = 1
    @wkst = :mo
    @id = rand(100)
    @duration = 0 # 1 day
  end

  FREQ = [:weekly, :monthly]
  DAYS = [:su, :mo, :tu, :we, :th, :fr, :sa]

  def convert_by_day(days_of_week, offset = '')
    selected_days = days_of_week.map do |day|
      d = day.downcase.to_sym
      DAYS.include?(d) ? (offset + d.to_s) : nil
    end
    selected_days.compact.join(",")
  end

  def convert_by_month_day(days_of_month)
    selected_days = days_of_month.map do |day|
      day.to_i != 0 ? day : nil
    end
    selected_days.compact.join(",")
  end

  # Returns the date that satisfies the offset and wday
  # used for "first Monday of the month" or "last Monday of the month"
  # offset has to be > 0
  # TODO: isn't dependent on Schedule. Might be better as apart of the date object
  def day_of_month(year,month,offset,wday)
    first = Date.new(year,month) # first day of month
    last = Date.new(year,month).next_month - 1 # grab the last day
    if offset > 0
      # offset to get to the right wday
      wday_offset = wday - first.wday
      # if the start of the week is actually greater, then add 7 to to first instance
      wday_offset += 7 if wday_offset < 0
      # which instance are we looking for?
      week_offset = 7 * (offset-1)
      answer = first + wday_offset + week_offset
      # [last, answer].min
      if answer.month == month
        answer
      else
        day_of_month(year,month,-1,wday)
      end
    else
      # offset to get to the right wday
      wday_offset = wday - last.wday
      # if the offset is positive, we want to make it negative
      wday_offset -= 7 if wday_offset > 0
      # which instance are we looking for?
      week_offset = 7 * (offset+1)
      answer = last + wday_offset + week_offset
      # [first, answer].max
      if answer.month == month
        answer
      else
        day_of_month(year,month,1,wday)
      end
    end
  end

  # Take params from a form and build the needed attributes
  # Possible attributes:
  # name - name for schedule
  # freq - type of schedule, "weekly" or "monthly"
  # interval - how often the frequency should repeat
  # days_of_week - array of days the schedule gets applys to (ie ["Mo","We"])
  # days_of_week_offset - how to offset the days of the week, just a single number
  # duration - how long someone has to complete the task (0 = due same day)
  def create(params)
    @name = params[:name] if params[:name]

    if (params[:freq] && FREQ.include?(params[:freq].to_sym))
      @freq = params[:freq].to_sym
    end

    @interval = params[:interval].to_i if params[:interval]

    if params[:days_of_week] && params[:days_of_week_offset]
      @by_day = convert_by_day(params[:days_of_week], params[:days_of_week_offset])
    elsif params[:days_of_week]
      @by_day = convert_by_day(params[:days_of_week])
    end

    if params[:days_of_month]
      @by_month_day = convert_by_month_day(params[:days_of_month])
    end

    @duration = params[:duration].to_i if params[:duration]
  end
  
  # Check to see if it is valid
  def valid?
    if @name.nil? || @freq.nil?
      false
    elsif frequency_length < @duration
      false
    else
      true
    end
  end

  # simply used for validation - we'll keep the monthly simple for now
  def frequency_length
    if @freq == :daily
      @interval * 1
    elsif @freq == :weekly
      @interval * 7
    elsif @frequency == :monthly
      @interval * 29 # technically this is short, but I think it is fine for now
    end
  end

  # Converts @by_day to an nested array
  # The first part is the offset (default = 1) and second is wday number
  # offset would be used for things like "second Monday of the month" ([2,1])
  # 'mo' => [[1,1]]
  # 'mo,we,fr' => [[1,1],[1,3],[1,5]]
  def translate_by_day
    days = @by_day.split(',')
    days.map do |day|
      if day.length == 2
        [ 1, DAYS.index(day.to_sym)]
      elsif day.length == 3
        [ day[0].to_i, DAYS.index(day[1..-1].to_sym) ]
      else
        [ day[0..-3].to_i, DAYS.index(day[-2..-1].to_sym) ]
      end
    end
  end

  # for :weekly - returns index of first day in translate_by_day
  def first_day
    if @freq == :weekly || (@freq == :monthly && @by_day)
      days = translate_by_day
      first_day = days.sort {|x,y| x[1] <=> y[1] }.first
      days.index(first_day)
    end
  end

  # Will return the _first_ time this event should happen after a given date
  # `continue` option is if it should look into the following freq or not (ie look at the next week).
  #     Otherwise it returns nil.
  # Does not take into account the interval.
  def next_occurrence(start_date, continue=false)
    if @freq == :weekly
      wday = start_date.wday
      days = translate_by_day # i.e. [[1,1]] - 
      # we want the first occurance where wday <= given day
      # example: schedule is [:mo,:we,:fr]
      # days = [[1,1],[1,3],[1,5]]
      # if our start_date is Sunday (wday=0), we want to stop on Monday (0 <= 1)
      # if our start_date is Tuesday (wday=2), we want to stop on Wednesday ( 2 <= 3)
      # if our start_date is Saturday (wday=6), we want the following Monday
      day_index = days.index { |day| wday <= day[1] }
      # if it is nil, we want the earliest day of the week
      if continue && day_index.nil?
        # I'd like to assume they are in order, but is that guaranteed?
        day_index = first_day
        # We then need to bump up the start_date a week
        start_date+=7
      elsif day_index.nil?
        return nil
      end
      # day will be the wday of the first matching date
      day = days[day_index][1]
      # we want to return the start_date plus the number of days till the firt match
      start_date + (day - wday)
    elsif @freq == :monthly && @by_day
      # Given the start_date we can grab month/year
      # go through each of the days and 
      # return if it is greater than start_date
      # else ask if it needs to go to the following month (recursion)
      days = translate_by_day
      days.each do |d|
        # puts "  looking for #{d}"
        day_in_month = day_of_month(start_date.year,start_date.month,*d)
        return day_in_month if day_in_month >= start_date
      end
      # if it didn't find a match, then ask if it needs to continue
      if continue
        # Call the next month
        next_month = Date.new(start_date.year,start_date.month+1)
        self.next_occurrence(next_month, continue)
      else
        nil
      end
    elsif @freq == :monthly && @by_month_day
      # Given start_date we know the day of month and we loop around 
      # by_month_day until we find one bigger (unless negative). If not, retun nil unless continue = true, 
      # in which case, grab the first one from by_month, and get it from the next month
      start_days_in_month = days_in_month(start_date.month, start_date.year)
      neg_start = start_date.mday - start_days_in_month
      month_days = @by_month_day.split(',').map(&:to_i).sort
      day_index = month_days.index do |mday| 
        if mday < 0
          # handle negatives
          neg_start <= mday
        else
          start_date.mday <= mday
        end
      end
      if !day_index.nil?
        day = month_days[day_index]
        Date.new(start_date.year, start_date.month, day)
      elsif continue
        Date.new(start_date.year, start_date.month+1, month_days.first)
      else
        nil
      end
    end
  end

  # Hack - this is from ActiveSupport - just use that method
  COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  def days_in_month(month, year = Time.now.year)
     return 29 if month == 2 && Date.gregorian_leap?(year)
     COMMON_YEAR_DAYS_IN_MONTH[month]
  end

  # Returns the first day for the frequency
  def first_group(start_date)
    if @freq == :weekly
      wday = translate_by_day[first_day][1]
      start_date + (wday - start_date.wday)
    # elsif @freq == :monthly
    #   day = translate_by_day[first_day]
    #   day_of_month(start_date.year,start_date.month,*day)
    end
  end

  # Returns the first date, for a grouping of events
  # i.e. if a schedule is MWF, then it will return the Monday
  # if it is every other week then it will return the following Monday that matches
  def next_group(first_occurrence,after_date)
    # Offset to add to the first_occurrence
    period = 0

    # period = days between repeated events
    if @freq == :weekly
      period = 7.0 * self.interval
    else
      nil
    end

    # diff = days between our `after_date` and the `first_occurrence`
    diff = after_date - first_occurrence
    # diff = 0 if diff < 0
    # ( diff / period ) - we want to find how many `period`s happened during that `diff`
    # _.ceil - we want to round up so that we usually get at least one period
    # _ * period - multiply by that period to get the right offset
    # _ = days on or after which our next occurance is
    days_after = ( diff / period ).ceil * period
    # puts "days_after = ( #{diff} / #{period} ).ceil * #{period} = #{days_after}"
    first_occurrence + days_after
  end

  # Finds the next occurance of the schedule as long as it is between the two dates
  # TODO: Possible refactoring, pass in first_occurance, not start_date
  def next_date(start_date, after_date)
    # puts "\\nnext_date - start(#{start_date}) after(#{after_date})"
    first_occurrence = next_occurrence(start_date,true)
    # puts "  the first occurance is: #{first_occurrence}"

    if after_date < first_occurrence
      # puts "  return the first_occurrence"
      first_occurrence
    elsif n = next_occurrence(after_date)
      n
    # I don't like having this type of conditional here, but 
    # `first_group` and `next_group` don't make sense for :monthly
    elsif @freq == :monthly
      next_occurrence(after_date,true)
    else
      # Find the first group for this event happened
      first_group = first_group(first_occurrence)
      # puts "  found first group (#{first_group}) now calling recursively"
      next_date(start_date, next_group(first_group, after_date))
    end
  end

  # be able to grab the next x occurances after a given time
end
