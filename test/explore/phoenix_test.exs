defmodule Explore.PhoenixTest do
  use ExUnit.Case

  #   {:safe, [60, "a", [32, "href", 61, 34, "/", 34], 62, "Home", 60, 47, "a", 62]}
  # iex(11)> Phoenix.HTML.Link.link("Home", to: "/")
  # {:safe, [60, "a", [32, "href", 61, 34, "/", 34], 62, "Home", 60, 47, "a", 62]}
  # iex(12)> Phoenix.HTML.Link.link("Home", to: "/") |> Phoenix.HTML.safe_to_string
  # "<a href=\"/\">Home</a>"
  # iex(13)> Phoenix.HTML.Link.link("Home", to: "/") |> Phoenix.HTML.safe_to_string()
  # "<a href=\"/\">Home</a>"

  test "links" do
    lnk = Phoenix.HTML.Link.link("Home", to: "/")

    # The :safe key indicates the generated content is known to be safe (related to XSS protection)
    # The tuple's second element is an "IO list", an efficient representation used for IO.
    lnk_output = {:safe, [60, "a", [32, "href", 61, 34, "/", 34], 62, "Home", 60, 47, "a", 62]}
    str_output = "<a href=\"/\">Home</a>"

    assert lnk == lnk_output
    assert lnk_output |> Phoenix.HTML.safe_to_string() == str_output

    # Altogether
    assert Phoenix.HTML.Link.link("Home", to: "/")
           |> Phoenix.HTML.safe_to_string() ==
             "<a href=\"/\">Home</a>"
  end
end
