defmodule StructSimplifierTest do
  use ExUnit.Case
  alias StructSimplifierTest.{
    SomeStruct,
    StrangeStruct
  }

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
      "e" => [1, 2, nil],
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
      {"e", [1, 2, nil]},
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
      |> Jason.encode!()
      |> Jason.decode!()
      |> StructSimplifier.decode()

    assert s == eds
  end

  test "desimplify protocol" do

    ss = StrangeStruct.new()

    es = StructSimplifier.encode(ss)
    assert es["b"] == [2, 2]
    assert es["d"] == nil

    ds = StructSimplifier.decode(es)
    assert ss == ds

    es1 = %{es | "b" => [3, 4]}
    ds1 = StructSimplifier.decode(es1)

    assert ds1.b == 3

  end

  @skip "not for decoder mr"
  test "complex map" do
    a = %{{:a, 1} => 666}
    # Проблема с конвертацией ключа в строку. Я могу вместо ключей делать метки, а настоящий ключ хранить рядом по метке

    b =
      a
      |> StructSimplifier.encode() |> IO.inspect(label: "e")
      |> Jason.encode!() |> IO.inspect(label: "je")
      |> Jason.decode!() |> IO.inspect(label: "jd")
      |> StructSimplifier.decode()
      |> Map.new(fn {k, v} -> {StructSimplifier.decode(k), v} end)

    assert a == b
  end
end
