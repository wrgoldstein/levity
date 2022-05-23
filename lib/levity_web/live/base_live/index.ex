defmodule LevityWeb.BaseLive.Index do
  use LevityWeb, :live_view

  alias Levity.Metrics
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(Levity.PubSub, "filesystem")
    # Registry.register(Levity.Registry, "liveview", self())
    socket 
    |> assign(:base, list_views())
    |> assign(:sql, "select some columns")
    |> assign(:selected, %{})
    |> then(& {:ok, &1})
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

  defp list_views do
    Metrics.get_base("orders")
  end

  def handle_event("click_field", %{"field_id" => field_id, "view" => view}, socket) do
    # toggle the field
    socket 
    |> toggle_field(view, field_id)
    |> then(fn socket ->
       assign(socket, :sql, Metrics.construct_query(
        socket.assigns.base, Map.values(socket.assigns.selected)
       ))
    end)
    |> then(& {:noreply, &1})
  end

  def toggle_field(socket, view, field_id) do
    if field_id in Map.keys(socket.assigns.selected) do
      assign(socket, :selected, Map.delete(socket.assigns.selected, field_id))
    else
     field = Enum.find(socket.assigns.base["views"], fn {v, _} -> v == view end)
      |> then(fn {_view, fields} -> fields end)
      |> Enum.find(fn field -> field.id == field_id end)

      assign(socket, :selected, Map.put(socket.assigns.selected, field_id, field))
    end
  end

  def handle_info({:metrics, metrics}, socket) do
    {:noreply, assign(socket, :bases, metrics)}
  end
end
