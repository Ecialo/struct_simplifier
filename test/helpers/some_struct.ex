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
