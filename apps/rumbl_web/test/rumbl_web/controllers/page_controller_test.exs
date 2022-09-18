defmodule RumblWeb.PageControllerTest do
  use RumblWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    # We could (in theory) call the controller action directly (after proper init)
    # Getting the conn however, ensures we test the whole request, from Endpoint to the database calls
    # i.e. router |> pipelines |> controller |> context |> ecto
    conn = get(conn, "/")

    # This tests 3 things:
    #   1. received HTTP 200 OK response
    #   2. content-type was text/html
    #   3. returned body can be matched on
    assert html_response(conn, 200) =~ "Welcome to Rumbl.io!"
  end
end
