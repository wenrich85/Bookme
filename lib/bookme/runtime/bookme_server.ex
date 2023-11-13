defmodule Bookme.Runtime.BookmeServer do
  alias Bookme.Runtime.BookmeRegistry
  alias Bookme.Impl.Appointment
  import Bookme.Impl.Schedule
  use GenServer

  def start_link(custodian_name) do
    GenServer.start_link(__MODULE__, custodian_name, name: via_tuple(custodian_name))
  end

  def init(name) do
    {:ok, %{name: name}}
  end

  def handle_call(:list_schedule, _from, schedules) do
    {:reply, schedules, schedules}
  end

  def handle_call({:add_schedule, schedule}, _from, schedules) do
    new_schedule = new(schedule)
    schedules = create_week_or_add_schedule(schedules, new_schedule)
    {:reply, new_schedule, schedules}
  end

  def handle_call({:add_appointment, appointment}, _from, schedules) do
    add_or_canx_appointment(schedules, Appointment.new(appointment), &add_appointment/2)
  end

  def handle_call({:cancel_appointment, appointment}, _from, schedules) do
    add_or_canx_appointment(schedules, Appointment.new(appointment), &cancel_appointment/2)
  end

  def handle_call({:show_available_appointments, appointment}, _from, schedules) do
    new_appointment = Appointment.new(appointment)
    times = find_schedule(schedules, new_appointment)
    |> check_available_timeslots(new_appointment)
    {:reply, times, schedules}
  end

  defp create_week_or_add_schedule(schedules, schedule) do
    week = get_week_string(schedule.date)
    if Map.has_key?(schedules, week) do
      create_week_or_add_schedule(schedules, schedule, week)
    else
      Map.put(schedules, week, %{get_day_name(schedule.date) => schedule })
    end
  end

  defp create_week_or_add_schedule(schedules, schedule, week) do
    new_schedule = Map.put(
                              schedules[week],
                              get_day_name(schedule.date),
                              schedule)
    Map.replace!(schedules, week, new_schedule)
  end

  defp get_day_name(date), do: Timex.format!(date, "%A", :strftime)
  defp get_week_string(date), do: Timex.beginning_of_week(date, :sun) |> Timex.format!("%Y-%m-%d", :strftime)

  defp find_week_by_appointment(schedules, appointment) do
    week = get_week_string(appointment.interval.from)
    schedules[week]
  end

  defp find_day_by_appointment(week, appointment) do
    day = get_day_name(appointment.interval.from)
    week[day]
  end

  defp find_schedule(schedules, appointment) do
    case find_week_by_appointment(schedules, appointment) do
      nil ->
        {:reply, "No schedule exists for this week", schedules}
      week ->
        #find schedule for appointment's day
        case find_day_by_appointment(week, appointment) do
          nil ->
            {:reply, "No schedule exists for this day", schedules}
            #add appointment
          day ->
            day
          end
    end
  end

  defp add_or_canx_appointment(schedules, appointment, action) do
    new_schedule = action.(find_schedule(schedules, appointment), appointment)
    schedules = create_week_or_add_schedule(schedules, new_schedule)
    {:reply, new_schedule, schedules}
  end

  defp via_tuple(name) do
    BookmeRegistry.via_tuple({__MODULE__, name})
  end
end
