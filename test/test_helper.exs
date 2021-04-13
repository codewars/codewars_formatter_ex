formatters = if System.get_env("CODEWARS") != nil, do: [CodewarsFormatter], else: [ExUnit.CLIFormatter]
ExUnit.start(formatters: formatters)
