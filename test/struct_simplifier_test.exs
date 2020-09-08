defmodule StructSimplifierTest do
  use ExUnit.Case
  alias StructSimplifierTest.SomeStruct

  doctest StructSimplifier
  doctest StructSimplifier.Decoder
  doctest StructSimplifier.Simplifable

  test "invariant" do
    s = SomeStruct.new()
    eds = s |> StructSimplifier.encode() |> StructSimplifier.decode()
    assert s == eds
  end

  test "map/pairlist eq" do
    map = %{
      "__t__" => "Elixir.StructSimplifierTest.SomeStruct",
      "a" => 1,
      "b" => 2.0,
      "c" => "ololo",
      "d" => [{"__t__", "Elixir.StructSimplifierTest.Vector"}, {"x", 1}, {"y", 2}],
      "e" => [1, 2, 3],
      "f" => %{
        "__t__" => 1,
        "__a__a" => 1,
        "b" => 11
      }
    }

    pairlist = [
      {"__t__", "Elixir.StructSimplifierTest.SomeStruct"},
      {"a", 1},
      {"b", 2.0},
      {"c", "ololo"},
      {"d", [{"__t__", "Elixir.StructSimplifierTest.Vector"}, {"x", 1}, {"y", 2}]},
      {"e", [1, 2, 3]},
      {"f", [{"__t__", 1}, {"__a__a", 1}, {"b", 11}]}
    ]

    assert StructSimplifier.decode(map) == StructSimplifier.decode(pairlist)
  end

  test "forward/backward compatibility" do
    s = SomeStruct.new()

    eds =
      s
      |> StructSimplifier.encode()
      |> Map.drop(["a"])
      |> Map.put("ff", 1488)
      |> StructSimplifier.decode()

    assert eds == %{s | a: nil}
  end

  test "braindead jsonify" do
    s = SomeStruct.new()

    eds =
      s
      |> StructSimplifier.encode()
      |> Jason.encode()
      |> Jason.decode()
      |> StructSimplifier.decode()

    assert s == eds
  end
end
