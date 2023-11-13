defmodule Bookme.Runtime.SystemSupervisor do
  alias Bookme.Runtime.ScheduleManager

  def start_link() do
    Supervisor.start_link(
      [
        Bookme.Runtime.BookmeRegistry,
        ScheduleManager
      ],
      strategy: :one_for_one,
      name: BookmeSystemSupervisor
    )
  end
end
