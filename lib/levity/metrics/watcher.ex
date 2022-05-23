defmodule Levity.Metrics.Watcher do
  @moduledoc """
  We could have this server watch for changes 
  """
  use GenServer

  alias Phoenix.LiveView
  

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_args) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: ["metrics/"], name: :watcher)
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info({:register_liveview, pid}, %{liveviews: liveviews} = state) do
    # Your own logic for path and events
    IO.puts "registered a pid!"
    {:noreply, %{liveviews: [pid | liveviews]}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic for path and events
    case HXL.decode_file(path) do
      {:ok, updated_metric_defs} ->
        Phoenix.PubSub.broadcast(Levity.PubSub, "filesystem", {:metrics, updated_metric_defs})
    end
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic when monitor stop
    {:noreply, state}
  end
end