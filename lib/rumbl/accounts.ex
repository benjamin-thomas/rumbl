defmodule Rumbl.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Rumbl.Accounts.User

  @spec list_users :: [User.t(), ...]
  def list_users do
    [
      %User{id: "1", name: "José", username: "josevalim"},
      %User{id: "2", name: "Bruce", username: "redrapids"},
      %User{id: "3", name: "Chris", username: "chrismccord"}
    ]
  end

  @spec get_user(String.t()) :: User.t() | nil
  def get_user(id) do
    Enum.find(list_users(), fn u -> u.id == id end)
  end

  @spec get_user_by(any) :: User.t() | nil
  def get_user_by(params) do
    Enum.find(list_users(), fn u ->
      Enum.all?(params, fn {key, val} -> Map.get(u, key) == val end)
    end)
  end
end
