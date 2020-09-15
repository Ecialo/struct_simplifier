defmodule StructSimplifier.Decoder do
  @moduledoc """
  How to decode data from simplified format. Shipped with this:
      iex> StructSimplifier.Decoder.decode(1)
      1

      iex> StructSimplifier.Decoder.decode(1.0)
      1.0

      iex> StructSimplifier.Decoder.decode("123")
      "123"

      iex> StructSimplifier.Decoder.decode(nil)
      nil

      iex> StructSimplifier.Decoder.decode(true)
      true

      iex> StructSimplifier.Decoder.decode("__a__lol")
      :lol

      iex> StructSimplifier.Decoder.decode([["__t__", 0], 1, 2, 3])
      {1, 2, 3}

      iex> StructSimplifier.Decoder.decode([1, 2, 3])
      [1, 2, 3]

      iex> StructSimplifier.Decoder.decode(%{"__t__" => 1, "__a__a" => 1, "__i__2" => 2, "3" => 3})
      %{:a => 1, 2 => 2, "3" => 3}
  """
  @type_field "__t__"
  @atom_field "__a__"
  @int_field "__i__"
  @map_type 1
  @tuple_field [@type_field, 0]
  @map_field {@type_field, @map_type}

  def decode([@tuple_field | rest]) do
    rest
    |> Enum.map(&decode/1)
    |> List.to_tuple()
  end

  def decode([@map_field | rest]) do
    Map.new(rest, &decode_map/1)
  end

  def decode([{@type_field, struct_name} | rest]) do
    struct_name = String.to_atom(struct_name)
    fields = Enum.map(rest, &decode_field/1)
    struct(struct_name, fields)
  end

  def decode(%{@type_field => @map_type} = map) do
    map
    |> Map.drop([@type_field])
    |> Map.new(&decode_map/1)
  end

  def decode(%{@type_field => struct_name} = struct_) do
    struct_name = String.to_atom(struct_name)

    fields =
      struct_
      |> Map.drop([@type_field])
      |> Enum.map(&decode_field/1)

    struct(struct_name, fields)
  end

  def decode(list) when is_list(list) do
    Enum.map(list, &decode/1)
  end

  def decode(<<@atom_field, atom::binary()>>), do: String.to_atom(atom)

  def decode(any_other), do: any_other

  defp decode_map({k, v}) do
    {decode_key(k), decode(v)}
  end

  defp decode_key(<<@int_field, int::binary()>>), do: String.to_integer(int)
  defp decode_key(key), do: decode(key)

  def type_field, do: @type_field
  def struct_field(field), do: {@type_field, field}
  def map_field, do: @map_field
  def map_type, do: @map_type
  def tuple_field, do: @tuple_field

  def atom_field, do: @atom_field
  def int_field, do: @int_field

  defp decode_field({k, v}) do
    {String.to_atom(k), decode(v)}
  end
end
