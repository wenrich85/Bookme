defmodule Bookme do
alias Bookme.Runtime.BookmeRegistry

  def start_schedule(name) do
    Bookme.Runtime.ScheduleManager.start_schedule(name)
  end

  def list_schedule(name) do
    GenServer.call(schedule_server_name(name), :list_schedule)
  end

  def add_schedule(name, schedule) do
    GenServer.call(schedule_server_name(name), {:add_schedule, schedule})
  end

  def add_appointment(name, appointment) do
    GenServer.call(schedule_server_name(name), {:add_appointment, appointment})
  end

  def cancel_appointment(name, appointment) do
    GenServer.call(schedule_server_name(name), {:cancel_appointment, appointment})
  end

  def show_appointment_times(name, appointment) do
    GenServer.call(schedule_server_name(name), {:show_available_appointments, appointment})
  end

  defp schedule_server_name(name) do
    BookmeRegistry.via_tuple({Bookme.Runtime.BookmeServer, name})
  end
end
