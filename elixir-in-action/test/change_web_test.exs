defmodule HttpServerTest do
  use ExUnit.Case, async: false
  use Plug.Test

  test "no events" do
    assert get("/events?pr=46").status == 200
    assert get("/events?pr=46").resp_body == ""
  end

  test "adding an events" do
    resp = post("/add_event?pr=44&comment=recheck test")

    assert resp.status == 200
    assert resp.resp_body == "OK"
    assert get("/events?pr=44").resp_body |> String.length == 40
  end

  defp get(path) do
    Change.Web.call(conn(:get, path), Change.Web.init([]))
  end

  defp post(path) do
    Change.Web.call(conn(:post, path), Change.Web.init([]))
  end
end
