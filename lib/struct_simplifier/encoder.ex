defprotocol StructSimplifier.Simplifable do
  @moduledoc """
  How to simplify data. Shipped with this:
      iex> StructSimplifier.Simplifable.encode(1)
      1

      iex> StructSimplifier.Simplifable.encode(1.0)
      1.0

      iex> StructSimplifier.Simplifable.encode("123")
      "123"

      iex> StructSimplifier.Simplifable.encode(nil)
      nil

      iex> StructSimplifier.Simplifable.encode(true)
      true

      iex> StructSimplifier.Simplifable.encode(:lol)
      "__a__lol"

      iex> StructSimplifier.Simplifable.encode({1, 2, 3})
      [["__t__", 0], 1, 2, 3]

      iex> StructSimplifier.Simplifable.encode([1, 2, 3])
      [1, 2, 3]

      iex> StructSimplifier.Simplifable.encode(%{:a => 1, 2 => 2, "3" => 3})
      %{"__t__" => 1, "__a__a" => 1, "__i__2" => 2, "3" => 3}
  """
  @fallback_to_any Application.get_env(:struct_simplifier, :fallback_to_any, true)
  def encode(data)
end

defimpl StructSimplifier.Simplifable, for: [Integer, Float, BitString] do
  def encode(v), do: v
end

defimpl StructSimplifier.Simplifable, for: Atom do
  alias StructSimplifier.Decoder

  def encode(nil), do: nil
  def encode(bool) when is_boolean(bool), do: bool
  def encode(atom), do: Decoder.atom_field() <> Atom.to_string(atom)
end

defimpl StructSimplifier.Simplifable, for: Tuple do
  alias StructSimplifier.Decoder

  def encode(tuple) do
    tuple
    |> Tuple.to_list()
    |> @protocol.encode()
    |> List.insert_at(0, Decoder.tuple_field())
  end
end

defimpl StructSimplifier.Simplifable, for: List do
  def encode(list) do
    Enum.map(list, &@protocol.encode/1)
  end
end

defimpl StructSimplifier.Simplifable, for: Map do
  alias StructSimplifier.Decoder

  def encode(map) do
    map
    |> Map.new(fn {k, v} -> {encode_key(k), @protocol.encode(v)} end)
    |> Map.put(Decoder.type_field(), Decoder.map_type())
  end

  def encode_key(k) when is_integer(k) do
    Decoder.int_field() <> Integer.to_string(k)
  end

  def encode_key(k), do: @protocol.encode(k)
end

defimpl StructSimplifier.Simplifable, for: Any do
  alias StructSimplifier.Decoder

  def encode(struct_) do
    struct_name = Atom.to_string(struct_.__struct__)

    struct_
    |> Map.from_struct()
    |> Map.new(fn {k, v} -> {Atom.to_string(k), @protocol.encode(v)} end)
    |> Map.put(Decoder.type_field(), struct_name)
  end
end
