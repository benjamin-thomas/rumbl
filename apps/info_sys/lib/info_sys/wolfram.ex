defmodule InfoSys.Wolfram do
  import SweetXml

  alias InfoSys.Result

  @behaviour InfoSys.Backend

  @http Application.get_env(:info_sys, :wolfram)[:http_client] || :httpc
  @base "https://api.wolframalpha.com/v2/query"

  @impl true
  def name, do: "wolfram"

  @impl true
  def compute(query_str, _opts) do
    query_str
    |> fetch_xml()
    |> xpath(~x"/queryresult/pod[    contains(@title, 'Result')
                                  or contains(@title, 'Definitions')
                                  or contains(@title, 'Value')
                                ]
                            /subpod/plaintext/text()")
    |> build_results()
  end

  defp build_results(nil), do: []

  defp build_results(answer) do
    [%Result{backend: __MODULE__, score: 95, text: to_string(answer)}]
  end

  defp fetch_xml(query) do
    ## Keeping below for ref
    ## :httpc.request(:get, {"https://api.wolframalpha.com/v2/query", []}, [ssl: [verify: :verify_none]], [])

    # The book shows non-tls requests.
    # With TLS, Erlang's HTTP client generates an annoying warning by default:
    #   [warning] Description: 'Authenticity is not established by certificate path validation'
    # Which I don't want to see. I found the HTTP client API documentation confusing
    # so this is my best option for now
    # NOTE: it's an improvement over straight HTTP anyways
    @http.set_options(socket_opts: [verify: :verify_none])
    {:ok, {_, _, body}} = @http.request(String.to_charlist(url(query)))

    body
  end

  defp url(input) do
    "#{@base}?" <> URI.encode_query(appid: id(), input: input, format: "plaintext")
  end

  defp id, do: Application.fetch_env!(:info_sys, :wolfram)[:app_id]
end
