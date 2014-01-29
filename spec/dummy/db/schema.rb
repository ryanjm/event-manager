ActiveRecord::Schema.define do
  create_table :events, :force => true do |t|
    t.string  :freq
    t.integer :interval
    t.string :by_day
    t.string :by_month_day
    t.string :wkst
    t.integer :duration
    t.datetime :event_start
    t.timestamps
  end
end
