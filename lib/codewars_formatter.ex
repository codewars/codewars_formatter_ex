defmodule CodewarsFormatter do
  @moduledoc false
  use GenServer

  import ExUnit.Formatter,
    only: [format_test_failure: 5]

  def init(opts) do
    config = %{
      seed: opts[:seed],
      width: get_terminal_width(),
      test_timings: [],
      failure_counter: 0,
      skipped_counter: 0,
      excluded_counter: 0,
      invalid_counter: 0
    }

    {:ok, config}
  end

  def handle_cast({:suite_started, _opts}, config) do
    {:noreply, config}
  end

  def handle_cast({:suite_finished, _run_us, _load_us}, config) do
    {:noreply, config}
  end

  def handle_cast({:test_started, %ExUnit.Test{} = test}, config) do
    IO.puts("\n<IT::>#{test.name}")
    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: nil} = test}, config) do
    IO.puts("\n<PASSED::>Test Passed")
    IO.puts(test_completed(test))

    test_timings = update_test_timings(config.test_timings, test)
    config = %{config | test_timings: test_timings}

    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:excluded, _}}}, config) do
    IO.puts("\n<LOG::>Test Excluded")
    IO.puts("\n<COMPLETEDIN::>")

    config = %{config | excluded_counter: config.excluded_counter + 1}

    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:skipped, _}}}, config) do
    IO.puts("\n<LOG::>Test Skipped")
    IO.puts("\n<COMPLETEDIN::>")

    config = %{config | skipped_counter: config.skipped_counter + 1}

    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:invalid, _}}}, config) do
    IO.puts("\n<FAILED::>Invalid Test")
    IO.puts("\n<COMPLETEDIN::>")

    config = %{config | invalid_counter: config.invalid_counter + 1}

    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:failed, failures}} = test}, config) do
    print_logs(test.logs)

    # TODO Make the failure message less verbose. Remove redundant information. Collapse stacktrace.
    formatted =
      format_test_failure(
        test,
        failures,
        config.failure_counter + 1,
        config.width,
        &formatter(&1, &2, config)
      )

    IO.puts(["\n<FAILED::>", escape_lf(formatted)])
    IO.puts(test_completed(test))

    test_timings = update_test_timings(config.test_timings, test)
    failure_counter = config.failure_counter + 1

    config = %{
      config
      | test_timings: test_timings,
        failure_counter: failure_counter
    }

    {:noreply, config}
  end

  def handle_cast({:module_started, %ExUnit.TestModule{name: name, file: _}}, config) do
    IO.puts("\n<DESCRIBE::>#{inspect(name)}")
    {:noreply, config}
  end

  def handle_cast({:module_finished, %ExUnit.TestModule{state: nil}}, config) do
    IO.puts(group_completed(config.test_timings))
    {:noreply, config}
  end

  def handle_cast({:module_finished, %ExUnit.TestModule{state: {:failed, _}}}, config) do
    IO.puts(group_completed(config.test_timings))
    {:noreply, config}
  end

  def handle_cast(:max_failures_reached, config) do
    IO.puts("--max-failures reached, aborting test suite")
    {:noreply, config}
  end

  def handle_cast(_, config) do
    {:noreply, config}
  end

  defp test_completed(%ExUnit.Test{time: time}) do
    "\n<COMPLETEDIN::>#{format_duration(time)}"
  end

  defp group_completed(timings) do
    "\n<COMPLETEDIN::>#{format_duration(Enum.sum(timings))}"
  end

  defp format_duration(micro) do
    :io_lib.format('~.4f', [micro / 1_000]) |> List.to_string()
  end

  defp update_test_timings(timings, %ExUnit.Test{time: time}) do
    [time | timings]
  end

  defp formatter(:diff_enabled?, _, _), do: false
  defp formatter(:blame_diff, msg, _), do: "-" <> msg <> "-"
  defp formatter(_, msg, _), do: msg

  defp get_terminal_width do
    case :io.columns() do
      {:ok, width} -> max(40, width)
      _ -> 80
    end
  end

  defp print_logs(""), do: nil
  defp print_logs(output), do: IO.puts(["\n<LOG::-Logs>", escape_lf(output)])

  defp escape_lf(s), do: String.replace(s, "\n", "<:LF:>")
end
