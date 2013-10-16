# A single instance of when an inspection should be performed
class ScheduleTodo
  attr_accessor :id
  attr_accessor :inspection_structure_id
  attr_accessor :schedule_item
  attr_accessor :start_date # when they can start it
  attr_accessor :end_date # when it has to be done
  # in rails we probably want to make start_date be the beginning of the day and
  # end_date the end of the day.
  # If we do that, we can probably refactor `Schedule`'s next_date method to handle this.
  # That way we don't have to add 1 to the todo's date inside of `ScheduleItem`

  def initialize
    @id = rand(100)
    @inspection_structure_id = rand(100)
  end

  def ==(other)
    self.inspection_structure_id == other.inspection_structure_id &&
      self.schedule_item == other.schedule_item &&
      self.start_date == other.start_date
  end
end
