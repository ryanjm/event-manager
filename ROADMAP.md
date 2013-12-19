# ROADMAP

This kind of serves as a general TO-DO list and a small projection of where the project is headed.

## Currently working on v0.0.1

## v0.0.2

The goal here is to clean up the API and be able to publish this as a gem.

- Be able to add `event_manager` to a model and get the following methods
- `valid_event_manager?` - to validate if the event related fields are filled out and valid.
- `next_event_after(date)` - return the next occurance of the event after a given `date`.
- `events_between(start_date, end_date)` - return array of dates on which the event repeats between these two.
- Have working tests for gem with TavisCI

## v0.0.3


## v0.1.0

- Add migration generator

## v0.1.5

- Add yearly frequency

## v0.2.0

- Add `until` and `count` to the events

## v1.0.0

- Add secondly, minutely, hourly, and daily frequencies
- Handle exceptions so someone can skip a particular event

## Future

- Add some view helpers. Views are usually something you want to customize but there are some helpers that could be created to make life easier.
- Maybe some JS helpers that would allow you to give examples of what the schedule would look like as you create it.
- Possibly look into adding other ics attributes and be able to generate iCalendar events.
