# StructSimplifier

Decompose struct in such form, that allow easy-peasy json encoding with elixir types preservation. Only restriction is `"__t__"` field in maps.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `struct_simplifier` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:struct_simplifier, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/struct_simplifier](https://hexdocs.pm/struct_simplifier).

