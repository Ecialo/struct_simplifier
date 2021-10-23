defmodule StructSimplifierTest.Vector do
  alias __MODULE__, as: Vector

  defstruct [:x, :y]

  def new(x, y) do
    %Vector{x: x, y: y}
  end
end

defmodule StructSimplifierTest.SomeStruct do
  alias StructSimplifierTest.Vector
  alias __MODULE__, as: SomeStruct

  @derive [StructSimplifier.Simplifable]
  defstruct [:a, :b, :c, :d, :e, :f]

  def new do
    %SomeStruct{
      a: 1,
      b: 2.0,
      c: "ololo",
      d: Vector.new(1, 2),
      e: [1, 2, 3],
      f: %{:a => 1, "b" => 11}
    }
  end
end

defmodule StructSimplifierTest.StrangeStruct do
  alias __MODULE__, as: StrangeStruct

  defstruct [:a, :b, :c, :d]

  def new do
    %StrangeStruct{
      a: 1,
      b: 2,
      c: 3,
      d: 4
    }
  end

  defimpl StructSimplifier.Simplifable do
    alias StructSimplifier.Encoder
    # require StructSimplifier.Encoder
    def encode(s) do
      naive_s = Encoder.naive_encode(s)

      %{naive_s | "b" => [s.b, s.b]}
      |> Map.drop(["d"])
    end
  end

  defimpl StructSimplifier.Desimplifable do
    def decode(struct, fields) do
      %{struct | d: 4, b: hd(fields[:b])}
    end
  end

end
