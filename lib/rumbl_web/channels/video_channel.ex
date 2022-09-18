defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  alias Rumbl.{Accounts, Multimedia}
  alias RumblWeb.AnnotationView

  @impl true
  def join("videos:" <> video_id, params, socket) do
    send(self(), :after_join)
    last_seen_id = params["last_seen_id"]
    # socket = assign(socket, :video_id, String.to_integer(video_id))
    video_id = String.to_integer(video_id)
    # video = Multimedia.get_video!(video_id) # that would generate an extra SQL request
    video = %Multimedia.Video{id: video_id}

    annotations =
      video
      |> Multimedia.list_annotations(last_seen_id)
      |> Phoenix.View.render_many(AnnotationView, "annotation.json")

    # :timer.send_interval(5000, :ping)
    {:ok, %{annotations: annotations}, assign(socket, :video_id, video_id)}
  end

  @impl true
  def handle_info(:after_join, socket) do
    push(socket, "presence_state", RumblWeb.Presence.list(socket))
    {:ok, _} = RumblWeb.Presence.track(socket, socket.assigns.user_id, %{device: "browser"})
    {:noreply, socket}
  end

  # @impl true
  # def handle_info(:ping, socket) do
  #   count = socket.assigns[:count] || 1

  #   # Send event to the socket (to the JavaScript client)
  #   push(socket, "ping", %{count: count})

  #   {:noreply, assign(socket, :count, count + 1)}
  # end

  @impl true
  def handle_in(event, params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annotation", params, user, socket) do
    case Multimedia.annotate_video(user, socket.assigns.video_id, params) do
      {:ok, annotation} ->
        broadcast!(socket, "new_annotation", %{
          id: annotation.id,
          user: RumblWeb.UserView.render("user.json", %{user: user}),
          body: annotation.body,
          at: annotation.at
        })

        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
