defmodule Explore.PhoenixTest do
  use ExUnit.Case

  # Run tests with:
  #   ./manage/dev/tix_start

  # To debug a test with pry:
  #   - add:
  #     - require IEx; IEx.pry()
  #   - then run:
  #     - iex -S mix test ./test/explore/phoenix_test.exs --trace
  #     - call `respawn` to resume

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

  test "rendering view funcs" do
    user = Rumbl.Accounts.get_user("1")
    assert "José" == user.name

    [module, template, assigns] = [RumblWeb.UserView, "user.html", %{user: user}]

    # Can't test `RumblWeb.UserView.render()`, the API changed for LiveView it seems...
    #
    # view = RumblWeb.UserView.render(template, assigns)
    # require IEx
    # IEx.pry()

    # assert %Phoenix.LiveView.Rendered{
    #          dynamic: :dynamic_fn_ref,
    #          fingerprint: String.to_integer("47838554191055764365378265403557096053"),
    #          root: false,
    #          static: ["<strong>", "</strong> (", ")\n"]
    #        } ==
    #          Phoenix.HTML.safe_to_string(view)

    # String.to_integer() to circumvent auto formatter
    assert %Phoenix.LiveView.Rendered{
             dynamic: :dynamic_fn_ref,
             fingerprint: String.to_integer("47838554191055764365378265403557096053"),
             root: false,
             static: ["<strong>", "</strong> (", ")\n"]
           } == %{Phoenix.View.render(module, template, assigns) | dynamic: :dynamic_fn_ref}

    assert "<strong>José</strong> (1)\n" ==
             Phoenix.View.render_to_string(module, template, assigns)
  end
end
