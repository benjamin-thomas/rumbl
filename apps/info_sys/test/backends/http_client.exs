defmodule InfoSys.Test.HttpClient do
  @wolfram_xml File.read!("../info_sys/test/fixtures/wolfram.xml")

  def set_options(_), do: nil

  def request(url) do
    url = to_string(url)

    cond do
      String.contains?(url, "1+%2B+1") -> {:ok, {[], [], @wolfram_xml}}
      true -> {:ok, {[], [], "<queryresult></queryresult>"}}
    end
  end
end
