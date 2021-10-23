defmodule StructSimplifier.Common do

  defmacro __using__(_opts) do
    quote do
      @type_field "__t__"
      @atom_field "__a__"
      @int_field "__i__"
      @map_type 1
      @tuple_field [@type_field, 0]
      @map_field {@type_field, @map_type}
    end
  end

end
