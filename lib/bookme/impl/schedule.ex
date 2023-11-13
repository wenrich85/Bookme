defmodule Bookme.Impl.Schedule do
  use Timex
  defstruct ~w[schedule_id start_time end_time duration date appointments availability increment]a

  def new(%{start_time: start_time, end_time: end_time, duration: duration, date: date}) do
    %__MODULE__{
      start_time: start_time,
      end_time: end_time,
      duration: duration,
      date: date,
      appointments: [],
      availability: [Interval.new(from: start_time, until: [minutes: calculate_minutes(start_time, end_time)])],
      increment: 15
    }
  end


  def check_available_timeslots(schedule, appointment) do
    duration = calculate_minutes(appointment.interval.from, appointment.interval.until)
    Enum.map(get_all_timeslots(schedule),
    &Interval.new(from: &1.start_time, until: [minutes: duration], step: [minutes: 15]))
    # |> Enum.filter(&Interval.contains?(List.first(schedule.availability), &1))
    |>loop_through_availability(schedule.availability)
  end

  def add_appointment(schedule, appointment) do
    struct!(schedule, availability: find_availabile_interval(schedule.availability, appointment))
    |> struct!(appointments: [appointment | schedule.appointments ])
  end

  def show_appointment_times(schedule) do
    get_all_timeslots(schedule)
    |> Enum.map(&Timex.format!(&1.start_time, "%H:%M", :strftime))
  end



  def cancel_appointment(schedule, appointment) do
    # remove appointment from list
    struct!(schedule, appointments: List.delete(schedule.appointments, appointment))
    # add appointment to list of availability
    |> struct!(availability: return_time_to_availability_and_sort(appointment.interval, schedule.availability))
    # merge availability list
    |> merge_availiabity()
  end

  defp get_all_timeslots(schedule) do
    Interval.new(from: schedule.start_time, until: [minutes: calculate_minutes(schedule)])
    |> Interval.with_step(minutes: schedule.increment)
    # |> Enum.map(&Timezone.convert(&1, Timezone.get("America/Chicago", &1)))
    # |> Enum.map(&Timex.format!(&1, "%H:%M", :strftime))
    |> Enum.map(&Bookme.Impl.Timeslot.create(%{start_time: &1, duration: schedule.increment}))
  end

  defp return_time_to_availability_and_sort( available_time, availability) do
    [ available_time | availability ]
     |> sort_availability()
  end

  defp loop_through_availability(intervals, availability) do
    Enum.map(availability,
    &Enum.filter(intervals, fn i -> Interval.contains?(&1, i) end))
    # |> Enum.map(&show_appointment_times(&1))
    |> List.flatten()
  end

  defp calculate_minutes(schedule) do
    Timex.diff(schedule.end_time, schedule.start_time)
    |> Duration.from_microseconds()
    |> Duration.to_minutes
    |> round
  end

  defp calculate_minutes(start_time, end_time) do
    calculate_minutes(%{start_time: start_time, end_time: end_time})
  end

  defp find_availabile_interval(availabilty, appointment) do
    unused_time_slots = Enum.filter(availabilty,
            &(!Interval.contains?(&1, appointment.interval)))
    Enum.filter(availabilty, &Interval.contains?(&1, appointment.interval))
    |> List.first()
    |> Interval.difference(appointment.interval)
    |> List.flatten(unused_time_slots)
  end
  def merge_availiabity(schedule) do
    schedule
     |>struct!(availability: Enum.reduce(schedule.availability, [], &reduce_interval(&2, &1)))
  end
  defp reduce_interval(acc, interval) when length(acc) < 1, do: [interval | acc ]

  defp reduce_interval(acc, interval) do
    last_interval = List.last(acc)
    case last_interval.until == interval.from do
       true ->
            acc
            |> List.update_at(length(acc)-1, &struct!(&1, until: interval.until))
            |> sort_availability()
        _ ->
            [ interval | acc]
            |> sort_availability()
    end
  end

  defp sort_availability(availability) do
    Enum.sort(availability, &(&1.from <= &2.from))
  end
end
