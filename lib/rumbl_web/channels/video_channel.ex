defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  @impl true
  def join("videos:" <> video_id, _params, socket) do
    socket = assign(socket, :video_id, String.to_integer(video_id))

    # :timer.send_interval(5000, :ping)
    {:ok, socket}
  end

  # @impl true
  # def handle_info(:ping, socket) do
  #   count = socket.assigns[:count] || 1

  #   # Send event to the socket (to the JavaScript client)
  #   push(socket, "ping", %{count: count})

  #   {:noreply, assign(socket, :count, count + 1)}
  # end

  @impl true
  def handle_in("new_annotation", params, socket) do
    broadcast!(socket, "new_annotation", %{
      user: %{username: "anon"},
      body: params["body"],
      at: params["at"]
    })

    {:reply, :ok, socket}
  end
end
