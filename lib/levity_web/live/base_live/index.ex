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
    |> assign(:formatted_sql, "select some columns")
    |> assign(:results, nil)
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
    Metrics.get_base("shops")
  end

  @doc """
  When a field is clicked in the UI, the field is either added to or
  removed from the selection.

  NOTE: In order to allow a javascript library to format the SQL,
  we send an event directly via `push_event/3` and allow a hook
  defined in `app.js` to intercept the event and do the formatting.
  """
  def status_class(field, selected) do
    if Map.has_key?(selected, field.id), do: "active", else: "inactive"
  end

  def handle_event("click_field", %{"field_id" => field_id, "view" => view}, socket) do
    socket 
    |> toggle_field(view, field_id)
    |> then(fn socket ->
       sql = Metrics.construct_query(
        socket.assigns.base, Map.values(socket.assigns.selected)
       )
       assign(socket, :sql, sql)
       |> push_event("sql", %{sql: sql})
       |> push_event("clear", %{})
    end)
    |> assign(:results, nil)
    |> then(& {:noreply, &1})
  end

  def handle_event("run_query", _, socket) do
    {:ok, pid} = Postgrex.start_link(hostname: "localhost", username: "postgres", password: "postgres", database: "local_prod")
    results = Postgrex.query!(pid, socket.assigns.sql, [])
    {:noreply, assign(socket, :results, results)}
    socket
    |> assign(:results, results)
    |> push_event("results", %{fields: Map.values(socket.assigns.selected), columns: results.columns, rows: results.rows})
    |> then(& {:noreply, &1})
  end

  def handle_event("format_sql", %{"sql" => sql}, socket) do
    socket
    |> assign(:formatted_sql, sql)
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
