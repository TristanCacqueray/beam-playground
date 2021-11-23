defmodule Change.Web do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def child_spec(_arg) do
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: Application.fetch_env!(:eia, :port)],
      plug: __MODULE__
    )
  end

  get "/ping" do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "pong")
  end

  # curl 'http://localhost:5454/entries?pr=42'
  get "/events" do
    conn = Plug.Conn.fetch_query_params(conn)
    change_name = Map.fetch!(conn.params, "pr")

    entries =
      %{pr: change_name}
      |> Change.Cache.server_process()
      |> Change.Server.get_events()

    formatted_entries =
      entries
      |> Enum.map(&"#{&1.date} #{&1.comment}")
      |> Enum.join("\n")

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, formatted_entries)
  end

  # curl -d '' 'http://localhost:5454/add_event?pr=42&comment=recheck'
  post "/add_event" do
    conn = Plug.Conn.fetch_query_params(conn)
    change_name = Map.fetch!(conn.params, "pr")
    comment = Map.fetch!(conn.params, "comment")

    %{pr: change_name}
    |> Change.Cache.server_process()
    |> Change.Server.add_event(%{comment: comment})

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  match _ do
    Plug.Conn.send_resp(conn, 404, "not found")
  end
end
