defmodule RumblWeb.Auth do
  import Plug.Conn

  import Phoenix.Controller
  alias RumblWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    # `assign` is a function imported from Plug.Conn
    cond do
      # Quote from the book:
      #   If we see that we already have a current_user, we return the connection as-is
      #   Lets be clear. What we're doing here is controversial. We're adding this code to make
      #   our implementation more testable. We think the trade-off is worth it. We are *improving the contract*.
      #   If a user is in the `conn.assigns`, we honor it, no matter how it got there. We have an improved testing
      #   story that doesn't require us to write mocks.
      conn.assigns[:current_user] ->
        conn

      user = user_id && Rumbl.Accounts.get_user(user_id) ->
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    # This next line protects from session fixation attacks
    |> configure_session(renew: true)
  end

  def logout(conn) do
    delete_session(conn, :user_id)
    # Or drop the whole session
    # configure_session(conn, drop: true)
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access this page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
