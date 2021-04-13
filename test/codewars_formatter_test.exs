defmodule CodewarsFormatterTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  @config %{
    test_timings: [],
    failure_counter: 0,
    width: 80
  }

  test ":test_finished event with nil state outputs PASSED" do
    test = %ExUnit.Test{
      state: nil,
      name: "passing",
      case: "Example"
    }

    output =
      capture_io(fn ->
        {:noreply, _} = CodewarsFormatter.handle_cast({:test_finished, test}, @config)
      end)

    assert Regex.match?(~r/\n<PASSED::>Test Passed\n/, output)
  end
end
