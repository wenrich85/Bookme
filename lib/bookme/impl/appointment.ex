defmodule Bookme.Impl.Appointment do
  defstruct ~w[appointment_id interval location customer custodian]a

  def new(%{start_time: start_time, duration: duration}) do
    appt = %__MODULE__{
      interval: Timex.Interval.new(from: start_time, until: [minutes: duration]),
    }
    struct!(appt, appointment_id: create_appointment_id(appt))
  end

  defp create_appointment_id(appointment) do
    appointment.interval.from
    |> Timex.format!("%Y%m%d-%H%M", :strftime)
    |> add_end_time(appointment.interval.until)
  end

  defp add_end_time(id_string, until_date) do
    id_string <> Timex.format!(until_date, "-%H%M", :strftime)
  end

end
