defmodule Rumbl.Multimedia.Permalink do
  # @behaviour Ecto.Type

  # Inherits `embed_as/1` and `equal?/2`. I get warnings otherwise.
  # https://elixirforum.com/t/please-explain-ecto-type-embed-as-1/26552/3
  use Ecto.Type

  # Returns the underlying Ecto type.
  @spec type :: :id
  def type, do: :id

  # Called when external data is passed into Ecto. It's invoked when values in
  # queries are interpolated or also by the `cast` function in changesets.
  @spec cast(any) :: :error | {:ok, integer}
  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {int, _rest} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  def cast(n) when is_integer(n) do
    {:ok, n}
  end

  def cast(_) do
    :error
  end

  # Invoked when data is sent to the database.
  @spec dump(integer) :: {:ok, integer}
  def dump(n) when is_integer(n) do
    {:ok, n}
  end

  # Invoked when data is loaded from the database.
  @spec load(integer) :: {:ok, integer}
  def load(n) when is_integer(n) do
    {:ok, n}
  end
end
