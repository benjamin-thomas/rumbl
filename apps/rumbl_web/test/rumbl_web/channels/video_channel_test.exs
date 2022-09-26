defmodule RumblWeb.VideoChannelTest do
  use RumblWeb.ChannelCase, async: false
  import RumblWeb.TestHelpers

  setup do
    user = insert_user(name: "Gary")
    video = insert_video(user, title: "Testing")
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)
    {:ok, socket} = connect(RumblWeb.UserSocket, %{"token" => token})
    {:ok, socket: socket, user: user, video: video}
  end

  test "join replies with video annotation", %{socket: socket, video: video, user: user} do
    for body <- ~w(one two) do
      Rumbl.Multimedia.annotate_video(user, video.id, %{body: body, at: 0})
    end

    {:ok, reply, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})

    assert video.id == socket.assigns.video_id

    # Match part of the reply struct!
    assert %{annotations: [%{body: "one"}, %{body: "two"}]} = reply

    # Source: https://hexdocs.pm/phoenix/Phoenix.Presence.html
    # Testing with Presence
    #
    # Every time the fetch callback is invoked, it is done from a separate
    # process. Given those processes run asynchronously, it is often necessary
    # to guarantee they have been shutdown at the end of every test. This can be
    # done by using ExUnit's on_exit hook plus fetchers_pids function:
    #
    # The `fetch` callback is indeed called via `:after_join`, every time we connect to the "videos:*" channel.
    # Without this `on_exit` hook, I would get a bunch of connection errors otherwise.
    #
    # ...Oh no, I get random failures! And it's irrelevant since I chose to run the tests in *sync* mode anyways!
    # ... and then...
    # So to sum up I *do* need this exit block, combined with a quirky timeout at the beginning of the exit block, whew!
    on_exit(fn ->
      # Nasty bug: https://github.com/phoenixframework/phoenix/issues/3619
      :timer.sleep(1)

      for pid <- RumblWeb.Presence.fetchers_pids() do
        ref = Process.monitor(pid)
        assert_receive {:DOWN, ^ref, _, _, _}, 1000
      end
    end)
  end
end
