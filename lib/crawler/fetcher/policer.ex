defmodule Crawler.Fetcher.Policer do
  alias Crawler.Store

  @doc """
  ## Examples

      iex> Policer.police([level: 1, max_levels: 2, url: "http://policer/"])
      {:ok, [level: 1, max_levels: 2, url: "http://policer/"]}

      iex> Crawler.Store.add("http://policer/exist/")
      iex> Policer.police([level: 1, max_levels: 2, url: "http://policer/exist/"])
      {:error, "Not allowed to fetch with opts: [level: 1, max_levels: 2, url: \\\"http://policer/exist/\\\"]."}

      iex> Policer.police([level: 2, max_levels: 2])
      {:error, "Not allowed to fetch with opts: [level: 2, max_levels: 2]."}
  """
  def police(opts) do
    with true <- within_fetch_level?(opts),
         true <- not_fetched_yet?(opts)
    do
      {:ok, opts}
    else
      _ -> {:error, "Not allowed to fetch with opts: #{Kernel.inspect(opts)}."}
    end
  end

  defp within_fetch_level?(opts) do
    opts[:level] < opts[:max_levels]
  end

  defp not_fetched_yet?(opts) do
    !Store.find(opts[:url])
  end
end
