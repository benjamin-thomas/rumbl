defmodule Rumbl.Multimedia.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    belongs_to :user, Rumbl.Accounts.User
    belongs_to :category, Rumbl.Multimedia.Category

    field :description, :string
    field :title, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    # `cast` lists which fields the user may specify.
    # `validate_required` tells Ecto which fields **must be present** from the `cast` list.
    # That's why `user_id` can't be mentioned here.
    |> cast(attrs, [:url, :title, :description, :category_id])
    |> validate_required([:url, :title, :description])
  end
end
