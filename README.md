# CodewarsFormatter

ExUnit formatter for Codewars.

## Usage

```elixir
defp deps do
  [
    {:codewars_formatter, "~> 0.1", only: [:test]}
  ]
end
```

```elixir
ExUnit.configure formatters: [CodewarsFormatter]
```

## Credits

Derived from `ExUnit.CLIFormatter`.
