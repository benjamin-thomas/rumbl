defmodule Rumbl.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Rumbl.Repo
  alias Rumbl.Accounts.User

  import Ecto.Query

  @spec list_users :: [User.t(), ...]
  def list_users do
    Repo.all(User)
  end

  @spec get_user(String.t()) :: User.t() | nil
  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  @spec get_user_by(any) :: User.t() | nil
  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def change_registration(%User{} = user, params) do
    User.registration_changeset(user, params)
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @spec authenticate_by_username_and_pass(String.t(), String.t()) ::
          {:error, :not_found | :unauthorized} | {:ok, Rumbl.Accounts.User.t()}
  def authenticate_by_username_and_pass(username, given_pass) do
    user = get_user_by(%{username: username})

    cond do
      user && Pbkdf2.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        # use `no_user_verify` to protect against timing attacks
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end

  def list_users_with_ids(ids) do
    Repo.all(from(u in User, where: u.id in ^ids))
  end
end
