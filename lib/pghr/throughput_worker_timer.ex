defmodule Pghr.ThroughputWorkerTimer do
  use GenServer

  def start_link(lifetime) do
    GenServer.start_link(__MODULE__, lifetime, name: __MODULE__)
  end

  def init(lifetime) do
    IO.inspect(lifetime, label: "lifetime")
    Process.send_after(self(), :stop_run, lifetime)
    {:ok, lifetime}
  end

  def handle_info(:stop_run, _lifetime) do
    IO.inspect(label: "STOP RUN")
    Pghr.ThroughputWorkerSupervisor.stop_run()
    {:stop, {:shutdown, :work_done}, 0}
  end
end
