defmodule Rumbl.Accounts.User do
  @type t :: %Rumbl.Accounts.User{id: String.t(), name: String.t(), username: String.t()}
  defstruct [:id, :name, :username]
end
