# (WIP - NON FUNCTIONAL - NOT PUBLISHED) EventManager

EventManager is meant to make it easy to add and manage repeating schedules to your Rails models.


## Installation

Add this line to your application's Gemfile:

    gem 'event_manager'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install event_manager

## Usage

This gem currently doesn't work, but the goal is to be able to use it as described here.

EventManager requires a few columns in your model, so to add them run the generator:

```
rails generate event_manager MODEL
``` 

The assumption is that you've already created the model, we are just adding columns to an existing table.

In your model add the following:

```ruby
  event_manager
```

When you create a new event you'll need to specify a few attributes.

```ruby
MODEL.update_attributes(
  freq: 'monthly',
  interval: '1',
  days_of_week: ['Mo'],
  days_of_week_offset: "1",
  duration: '0'
  starting_at: DateTime.new
)
```

See the wiki for explication of each attribute.

With a saved object you can now get information about the repeating events.

```ruby
event.events_between(start_date, end_date)

event.next_event_after(date)
```

## Contributing

I'd love for you to help out with the project. Please see the [Contributing](CONTRIBUTING.md) section.

## Running Tests

There are some rspec tests already written.

```
$ bundle
$ rspec test
```

## Similar Projects

As far as I know these are the only other projects that are some what similar (for those looking for the best solution).

- [iCalendar](https://github.com/icalendar/icalendar) - Looks like a large gem to deal with iCalendar files. Looks like it is being maintained pretty well.
- [ri_cal](https://github.com/rubyredrick/ri_cal) - Also deals with iCalendar files. Last updated 3 years ago.
- [rails-scheduler](https://github.com/atd/rails-scheduler) - Looks like it is pretty close to this project of creating scheduled events.
