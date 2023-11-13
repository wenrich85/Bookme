defmodule Bookme.Impl.Timeslot do
  defstruct ~w[start_time duration isOpen?]a

  def create(%{start_time: start_time, duration: duration}),
  do: %__MODULE__{start_time: start_time, duration: duration, isOpen?: true}
end
