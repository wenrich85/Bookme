defmodule Bookme.Runtime.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Bookme.Runtime.SystemSupervisor.start_link()
  end
end
