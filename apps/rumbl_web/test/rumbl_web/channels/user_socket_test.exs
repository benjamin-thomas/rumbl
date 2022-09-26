defmodule RumblWeb.UserSocketTest do
  use RumblWeb.ChannelCase, async: true
  alias RumblWeb.UserSocket

  test "socket authentication with valid token" do
    token = Phoenix.Token.sign(@endpoint, "user socket", "123")
    assert {:ok, socket} = connect(UserSocket, %{"token" => token})
    assert "123" = socket.assigns.user_id
  end

  test "socket authentication with invalid token" do
    assert :error = connect(UserSocket, %{"token" => "123"})
    assert :error = connect(UserSocket, %{})
  end
end
