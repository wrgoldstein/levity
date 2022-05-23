defmodule LevityWeb.BaseLive.Index do
  use LevityWeb, :live_view

  alias Levity.Metrics
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(Levity.PubSub, "filesystem")
    # Registry.register(Levity.Registry, "liveview", self())
    {:ok, assign(socket, :bases, list_bases())}
  end


  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
  end

  defp apply_action(socket, :new, _params) do
    socket
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp list_bases do
    {:ok, metrics} = HXL.decode_file("metrics/customers.view")
    metrics
  end

  def handle_info({:metrics, metrics}, socket) do
    for base <- metrics, do: IO.inspect(base)
    {:noreply, assign(socket, :bases, metrics)}
  end
end
