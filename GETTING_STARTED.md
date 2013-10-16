# Getting Started

Scheduling code is not the easiest to understand so I want to do a quick outline of how to think about the code you'll find within this project.

## Encoding a Schedule

The first challenge is to figure out how to encode a schedule. How to save it to the database. This is why the iCalendar [RFC2445](http://www.ietf.org/rfc/rfc2445.txt) is so helpful. Smart people have already figure out a great way to encode _any_ schedule. Look at the schedule titled "4.3.10 Recurrence Rule".

There isn't an easy way to summaries it, but some of the big things are:

- frequency - specifies on what schedule something repeats. Right now we handle "weekly" and "monthly".
- interval - based on the frequency, how often does it repeat. For example if this was "2" and frequency was "weekly", then it would be "every other week".
- days of week - specify which days of the week an event happens on. For example you could have a "Monday, Wednesday, Friday, every other week".
- duration - how long does the event last for.

The last part you need to know is when the schedule should be started (right now this is actually on schedule_item, we should move this over).

## Figuring out next occurrence

Once you've encoded it, you now need to be able to work with the dates themselves.

There are two sets of methods. Internal methods to just decode our attributes above and to figure out specific time-related attributes. And then there are the methods we expect the user to use.

Now when you are figuring out the next occurrence after a given date (`after_date`) the process kind of looks like this (this is the `next_date` method in `Schedule`):

* Find the first occurrence of the event. The `start_event` (right now it is `start_date` on the `ScheduleItem`) date does not have to be the first occurrence. This provides flexibility to the user to be able to say "I want a Monday, Wednesday schedule that repeats every week, that starts May 1st".
* Then it is just a matter of figuring out of the first occurrence is what the user is looking for (if it is after `after_date`), if not, then things get a little tricky because we must figure out what kind of schedule it is and then find the next date based on that.

### Other Methods

`next_date`, `next_occurrence`, and `next_group` are really the heart and sole of this code. Those would be the best places to start.

`next_date` has been described above since that is the API the user should be using.

`next_occurrence` does all the hard math behind scheduling. The big thing is figuring out how to get numbers of a given date. So this might bean figuring out days of the week (0 = Sun, 1 = Mon, etc) or days of month.

`next_group` is used for weekly schedules. A "group" in this context is the days of the week attribute. So if the schedule is MWF then it will return the Monday of the schedule after a given date. If you give it a Wednesday, it will give you the following Monday (assuming it is an interval of 1).
