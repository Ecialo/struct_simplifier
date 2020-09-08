defmodule StructSimplifier do
  defdelegate encode(something), to: StructSimplifier.Simplifable

  defdelegate decode(something), to: StructSimplifier.Decoder
end
