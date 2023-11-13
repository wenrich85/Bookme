defmodule Bookme.Runtime.ScheduleManager do
alias Bookme.Runtime.BookmeServer

  def start_link() do
    IO.puts("Starting #{__MODULE__}...")
    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  def start_schedule(custodian_name) do
    case start_child(custodian_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp start_child(custodian_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {BookmeServer, custodian_name}
    )
  end
end
