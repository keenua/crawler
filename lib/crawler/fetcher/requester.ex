defmodule Crawler.Fetcher.Requester do
  @moduledoc """
  Makes HTTP requests.
  """

  alias Crawler.HTTP

  @fetch_opts [
    follow_redirect: true,
    max_redirect:    5,
  ]

  @doc """
  Makes HTTP requests via `Crawler.HTTP`.

  ## Examples

      iex> Requester.make(url: "fake.url", modifier: Crawler.Fetcher.Modifier)
      {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
  """
  def make(opts) do
    fetch_options = fetch_opts(opts) ++ [url: opts[:url]]
    headers = fetch_headers(opts, fetch_options)

    res = HTTP.get(opts[:url], headers, fetch_options)

    case res do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        opts[:reporter].report_success(fetch_options)
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        opts[:reporter].report_fail(fetch_options, "Non-200 status code", status_code)
      {:error, %HTTPoison.Error{reason: reason}} ->
        opts[:reporter].report_fail(fetch_options, reason, 0)
    end

    res
  end

  defp fetch_headers(opts, fetch_options) do
    [{"User-Agent", opts[:user_agent]}] ++ opts[:modifier].headers(opts, fetch_options)
  end

  defp fetch_opts(opts) do
    @fetch_opts ++ [recv_timeout: opts[:timeout]] ++ opts[:modifier].opts(opts)
  end
end
