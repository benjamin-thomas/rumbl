defmodule Rumbl.Accounts.User do
  # @type t :: %Rumbl.Accounts.User{id: String.t(), name: String.t(), username: String.t()}
  # defstruct [:id, :name, :username]

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :username, :string

    timestamps()
  end
end
