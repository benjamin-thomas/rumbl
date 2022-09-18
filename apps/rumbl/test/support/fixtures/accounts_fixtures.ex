defmodule Rumbl.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Rumbl.Accounts` context.
  """

  alias Rumbl.Accounts

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "some user",
        username: "user#{System.unique_integer([:positive])}",
        password: attrs[:password] || "supersecret"
      })
      |> Accounts.register_user()

    user
  end
end
