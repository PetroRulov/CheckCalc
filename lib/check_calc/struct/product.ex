defmodule CheckCalc.Struct.Product do
  @moduledoc false

  @type discount :: float() | nil
  @type discount_bulk :: 2..12 | nil

  defstruct [:code, :name, :price, :bogof, :discount_bulk, :discount]

  @type t :: %__MODULE__{
          code: String.t(),
          name: String.t(),
          price: Decimal.t(),
          bogof: boolean(),
          discount_bulk: discount_bulk,
          discount: discount
        }
end
